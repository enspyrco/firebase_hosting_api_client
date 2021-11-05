import 'dart:io';

void printIfVerbose(Object object) {
  if (Platform.environment['DEBUGGING'] == 'true') {
    print(object);
  }
}
