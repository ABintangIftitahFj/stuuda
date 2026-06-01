import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import '/services/input_security.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../screens/user/login.dart';
import '../../support/app_config.dart' as app_config;
import 'auth.dart' as auth;
import 'package:path/path.dart' as p;
import 'utils.dart';
import 'dart:developer';

String token = '';

_setHeaders() {
  token = auth.getAuthToken();
  return {
    'Content-type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
    // mark as ajax request
    'X-Requested-With': 'XMLHttpRequest',
    // 'X-Requested-With': 'ngrok-skip-browser-warning',
    // let the system knows this is mobile app request
    'api-request-signature': 'mobile-app-request',
    // 'api-request-signature': 'ngrok-skip-browser-warning',
    'Authorization': 'Bearer $token'
  };
}

typedef OnCallbackType = Function(Map<String, dynamic>? responseData);
Future /* <http.Response> */  post(
  String requestedUrl, {
  Map<String, dynamic>? inputData,
  BuildContext? context,
  bool? secured = false,
  List<String>? unSecuredFields,
  OnCallbackType? onSuccess,
  OnCallbackType? thenCallback,
  Function? onError,
  OnCallbackType? onFailed,
}) async {
  Map<String, dynamic>? newInputData = {};
  if ((secured == true) && (inputData != null)) {

    /* inputData = inputData.map((key, value) {
      if ((unSecuredFields != null) && unSecuredFields.contains(key)) {
        return value;
      } else {
        return InputSecurity().text(value);
      }
    }); */
    inputData.forEach((key, value) {
      // Inside the forEach loop where you process inputData:

      if ((unSecuredFields != null) && unSecuredFields.contains(key)) {
        newInputData[key] = value;
      } else {
        newInputData[InputSecurity().text(key)] =
            InputSecurity().text(value.toString());
      }
    });
  }
  Uri urlToProcess = apiUrl(requestedUrl);
  pr('http POST request: $urlToProcess');
  if ((inputData != null) && (inputData.isNotEmpty)) {
    pr('http post data: $inputData');
    pr(jsonEncode(newInputData.isEmpty ? inputData : newInputData));
  }
  final httpResponse = await http
      .post(
    urlToProcess,
    headers: _setHeaders(),
    body: jsonEncode(newInputData.isEmpty ? inputData : newInputData),
  )
      .then((value) {
    // process the further request
    _thenProcessing(value, inputData, onSuccess, context, thenCallback, onError,
        failedCallbackAction: onFailed);
    return value;
  });
  return httpResponse.body;
}

// http.Response
Future get(
  String requestedUrl, {
  BuildContext? context,
  OnCallbackType? onSuccess,
  OnCallbackType? thenCallback,
  Function? onError,
  Map<String, dynamic>? queryParameters,
  OnCallbackType? onFailed,
}) async {
  Uri urlToProcess =
      apiUrl(requestedUrl, queryParameters: queryParameters, context: context);
  pr('http GET request: $urlToProcess', lineNumber: 2);
  var httpResponse = await http
      .get(
    urlToProcess,
    headers: _setHeaders(),
  )
      .then((value) {
    // process the further request
    _thenProcessing(value, {}, onSuccess, context, thenCallback, null,
        failedCallbackAction: onFailed);
    return value;
  }).catchError((error) {
    if ((context != null) && (app_config.debug == true)) {
      showToastMessage(context, error.toString(), type: 'error');
    }
    pr("error $error");
    _thenProcessing(error.toString(), {}, null, context, thenCallback, onError,
        failedCallbackAction: onFailed);
    return error;
  });
  return httpResponse.body;
}

void uploadFile(String filename, String url,
    {BuildContext? context,
    OnCallbackType? onSuccess,
    OnCallbackType? thenCallback,
    Map<String, String> inputData = const {},
    Function? onError,
    Function? onFailed}) async {
  String fileName = p.basename(filename);
  String fileExtension = p.extension(fileName).toLowerCase();
  Map<String, String> mimeTypes = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.mp4': 'video/mp4',
    '.mov': 'video/quicktime',
    '.avi': 'video/x-msvideo',
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.aac': 'audio/aac',
    '.pdf': 'application/pdf',
    '.doc': 'application/msword',
    '.docx':
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    '.txt': 'text/plain',
  };

  String? mimeType = mimeTypes[fileExtension];

  if (mimeType != null) {
    var request = http.MultipartRequest('POST', apiUrl(url));
    request.headers.addAll(_setHeaders());

    if (inputData.isNotEmpty) {
      request.fields.addAll(inputData);
    }

    File file = File(filename);
    request.files.add(await http.MultipartFile.fromPath('filepond', filename,
        contentType: MediaType.parse(mimeType)));

    try {
      var response = await request.send();
      var responseFromStream = await http.Response.fromStream(response);
      _thenProcessing(
        responseFromStream,
        fileName,
        onSuccess,
        context,
        thenCallback,
        onError,
        failedCallbackAction: onFailed,
      );
    } catch (e) {
      pr("Error during upload: $e");
      if (onError != null) {
        onError(e.toString());
      }
    }
  } else {
    pr("Unsupported file type: $fileExtension");
    if (onError != null) {
      onError("Unsupported file type: $fileExtension");
    }
  }
}

void _thenProcessing(
    dynamic value,
    dynamic inputData,
    OnCallbackType? successCallbackAction,
    BuildContext? context,
    OnCallbackType? thenCallbackAction,
    Function? onError,
    {Function? failedCallbackAction}) {
  Map<String, dynamic> responseData;

  try {

    // Ensure value is of the expected type (e.g., a response object with a body)
    if (value == null || value.body == null) {
      throw Exception('Invalid response: value or body is null');
    }

    // Parse the response body as JSON
    responseData = jsonDecode(value.body);
  } catch (e) {
    pr("Value or body is null or invalid: $e");
    pr(e);

    // if (context != null || value.statusCode == 413) {
    //   showToastMessage(context!, 'Content Too Large', type: 'error');
    // }

    // Show error message in the UI
    if (context != null) {
      // pr("statusCode ${value.statusCode}");
      showToastMessage(context, 'Something went wrong', type: 'error');
    }



    // Handle onError callback
    if (onError != null) {
      if (value is String || value is int) {
        onError(value); // Pass the raw value to onError
      } else if (value != null && value.body != null) {
        onError(value.body); // Pass the body to onError
      } else {
        onError(e); // Pass the exception to onError
      }
    }

    // Return a default value or rethrow the error
    return; // Exit the function if there's an error
  }

  // Process the response data
  jsdd(responseData);

  // Update the notification count
  int notificationCount = getItemValue(
      responseData, 'client_models.notifications.notificationCount',
      fallbackValue: -1);
  if (notificationCount >= 0) {
    FBroadcast.instance().broadcast(
      "local.broadcast.notification_count",
      value: notificationCount,
    );
  }

  // Set the token if refreshed
  if (responseData['data']?['additional']?['token_refreshed'] != null) {
    auth.storeAuthToken(responseData['data']['additional']['token_refreshed']);
  }

  // Check if the user is authenticated
  if (responseData['data']?['auth_info']?['authorized'] == false) {
    auth.logout();
    if (context != null) {
      navigatePage(context, const LoginPage());
    }
  } else if (value.statusCode == 200) {
    // Handle success case
    if (thenCallbackAction != null) {
      thenCallbackAction(responseData);
    }
    if (responseData['reaction'] == 1) {
      if (successCallbackAction != null) {
        successCallbackAction(responseData);
      }
      if (context != null) {
        showSuccessMessage(context, responseData['data']['message']);
      }
    }else if (responseData['reaction'] == 21){
      if (successCallbackAction != null) {
        successCallbackAction(responseData);
      }
      if (context != null) {
        showSuccessMessage(context, responseData['data']['message']);
      }
    }
    else {
      if (failedCallbackAction != null) {
        failedCallbackAction(responseData);
      }
      if (context != null) {
        showToastMessage(context, responseData['data']['message'],
            type: 'error');
      }
    }
  }

  else if (value.statusCode == 422) {
    // Handle validation errors
    Map<String, dynamic> responseErrors = responseData['errors'];
    String errorString = responseData['message'];
    for (String key in responseErrors.keys) {
      String errorMessage = responseErrors[key][0];
      if (errorString != errorMessage) errorString += '\n $errorMessage';
    }
    if ((errorString != '') && (context != null)) {
      showToastMessage(context, errorString, type: 'error');
    }
  } else {
    // Handle other errors
    if (context != null) {
      showToastMessage(context, 'Something went wrong', type: 'error');
    }
    if (onError != null) {
      onError(responseData); // Pass the response data to onError
    }
    throw "DataTransport: Request Failed ${value.body}";
  }
}

