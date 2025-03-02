import 'package:cbj_smart_device/core/shared_variables.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/core_u/smart_device_manager_u.dart';
import 'package:cbj_smart_device/features/smart_device/infrastructure/datasources/core_d/manage_physical_components/device_pin_manager.dart';

void main(List<String> arguments) async {
  print('Smart device is activated');

  //  await configureInjection(Env.dev_pi);
  try {
    SharedVariables(arguments[0]);
  } catch (error) {
    print('Path/argument 1 is not specified');
    print('error: $error');
  }

  //  Setting device model and checking if configuration for this model exist
  await DevicePinListManager().setPhysicalDeviceType();

  SmartDeviceManagerU();
}
