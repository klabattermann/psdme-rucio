
#include <iostream>
#include <fstream>
#include <sstream>
#include <set>
#include <json.h>
#include <uuid/uuid.h>


std::string readFileIntoString(const std::string& path) {
    std::ifstream input_file(path);
    if (!input_file.is_open()) {
        std::cerr << "Could not open the file - '"
                  << path << "'" << std::endl;
        exit(EXIT_FAILURE);
    }
    return std::string((std::istreambuf_iterator<char>(input_file)), std::istreambuf_iterator<char>());
}

int main() {

    std::string filename("test.json");
    std::string jsonresp;
    jsonresp = readFileIntoString(filename);
    std::cout << jsonresp.c_str() << std::endl;

   
    std::string suuid("fd714986-b223-4ea3-8033-aa452c6a5db7");
    struct json_object* parsed_json = json_tokener_parse(jsonresp.c_str());

    struct json_object* request_id;
    json_object_object_get_ex(parsed_json, "request_id", &request_id);
    std::string str_request_id = request_id ? json_object_get_string(request_id) : "";

    std::cout << "hhh " << str_request_id << std::endl;

    if (str_request_id.empty() || str_request_id != suuid) {
        std::cout << "Empty or wrong request_id" << std::endl;
        exit(2);
    }

    struct json_object* responses = 0;
    json_object_object_get_ex(parsed_json, "responses", &responses);
    int size = responses ? json_object_array_length(responses) : 0;
    std::cout << "Response size " << size << std::endl;

    int error_count = 0;
    for (int i = 0 ; i < size; i++) {
        struct json_object* fileobj = json_object_array_get_idx(responses, i);

        // std::cout << "Response " << fileobj << std::endl;

        // Retrieve "error_text" attribute
        // Note: if it exists, this text should be appended to all other error messages
        struct json_object* fileobj_error_text = 0;
        json_object_object_get_ex(fileobj, "error_text", &fileobj_error_text);
        std::string error_text;

        if (!fileobj_error_text) {
            error_count++;
            std::cout << "No error text " << std::endl;
            continue;
        } else {
            error_text = json_object_get_string(fileobj_error_text);
            std::cout << "error text: " << error_text << std::endl;
        }

    } // end loop

    return 1;
}
