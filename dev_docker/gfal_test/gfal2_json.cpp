
#include <iostream>
#include <fstream>
#include <sstream>
#include <set>
#include <json.h>
#include <uuid/uuid.h>


string readFileIntoString(const string& path) {
    std::ifstream input_file(path);
    if (!input_file.is_open()) {
        std::cerr << "Could not open the file - '"
                  << path << "'" << std::endl;
        exit(EXIT_FAILURE);
    }
    return string((std::istreambuf_iterator<char>(input_file)), std::istreambuf_iterator<char>());
}



in main() {

    std::string filename("test.json");
    std::string jsonresp;
    jsonresp = readFileIntoString(filename);

    std::cout << jsonresp << std::endl;
    
    
    struct json_object* parsed_json = json_tokener_parse(jsonresp.c_str());

    if (!parsed_json) {
        for (int i = 0; i < nbfiles; i++) {
            gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__, "Malformed served response.");
        }
        return -1;
    }

    struct json_object* request_id;
    json_object_object_get_ex(parsed_json, "request_id", &request_id);
    std::string str_request_id = request_id ? json_object_get_string(request_id) : "";

    if (str_request_id.empty() || str_request_id != suuid) {
        for (int i = 0; i < nbfiles; i++) {
            gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__, "%s", "Request ID mismatch.");
        }
        return -1;
    }

    int ontape_count = 0;
    int error_count = 0;

    // Iterate over the file list
    struct json_object* responses = 0;
    json_object_object_get_ex(parsed_json, "responses", &responses);
    int size = responses ? json_object_array_length(responses) : 0;

    if (size != nbfiles) {
        for (int i = 0; i < nbfiles; i++) {
            gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__,
                            "Number of files in the request doest not match!");
        }
        return -1;
    }

    for (int i = 0 ; i < size; i++) {
        struct json_object* fileobj = json_object_array_get_idx(responses, i);

        if (!fileobj) {
            error_count++;
            gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__, "Malformed server response.");
            continue;
        }

        // Retrieve "error_text" attribute
        // Note: if it exists, this text should be appended to all other error messages
        struct json_object* fileobj_error_text = 0;
        json_object_object_get_ex(fileobj, "error_text", &fileobj_error_text);
        std::string error_text;

        if (!fileobj_error_text) {
          error_count++;
          gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__, "Error attribute missing.");
          continue;
        } else {
          error_text = json_object_get_string(fileobj_error_text);
        }

        // Retrieve "path" attribute
        struct json_object* fileobj_path = 0;
        json_object_object_get_ex(fileobj, "path", &fileobj_path);
        std::string path = fileobj_path ? json_object_get_string(fileobj_path) : "";
        collapse_slashes(path);

        if (path.empty() || !paths.count(path)) {
            error_count++;
            gfal2_xrootd_poll_set_error(&errors[i], ENOMSG, __func__, error_text.c_str(),
                                        "Wrong path: %s", path.c_str());
            continue;
        }

        // Retrieve "path_exists" attribute
        struct json_object* fileobj_exists = 0;
        json_object_object_get_ex(fileobj, "path_exists", &fileobj_exists);
        bool path_exists = json_obj_to_bool(fileobj_exists);

        if (!path_exists) {
            error_count++;
            gfal2_xrootd_poll_set_error(&errors[i], ENOENT, __func__, error_text.c_str(),
                                        "File does not exist: %s", path.c_str());
            continue;
        }

        // Retrieve "ontape" attribute
        struct json_object* fileobj_ontape = 0;
        json_object_object_get_ex(fileobj, "on_tape", &fileobj_ontape);
        bool ontape = json_obj_to_bool(fileobj_ontape);

        if (ontape) {
            ontape_count++;
            continue;
        }

        if (!error_text.empty()) {
            error_count++;
            gfal2_set_error(&errors[i], xrootd_domain, ENOMSG, __func__, "%s", error_text.c_str());
            continue;
        }

        // In case of no errors but the file is not yet archived, set EAGAIN
        if (!ontape) {
            gfal2_set_error(&errors[i], xrootd_domain, EAGAIN, __func__,
                            "File %s is not yet archived", path.c_str());
        }
    }

    // Free the top JSON object
    json_object_put(parsed_json);

    // All files are on tape: return 1
    if (ontape_count == nbfiles) {
        return 1;
    }

    // All files encountered errors: return -1
    if (error_count == nbfiles) {
        return -1;
    }

    // Some files are on tape, others encountered errors
    if (ontape_count + error_count == nbfiles) {
        return 2;
    }

    // Archiving in process: return 0
    return 0;
}
