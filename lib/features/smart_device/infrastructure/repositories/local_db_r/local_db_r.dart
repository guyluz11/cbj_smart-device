import 'package:cbj_smart_device/core/my_singleton.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/button_object_u/button_with_light_object.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/button_object_u/simple_button_object.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/smart_device_objects_u/abstracts_devices/smart_device_base.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/smart_device_objects_u/abstracts_devices/smart_device_base_abstract.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/smart_device_objects_u/simple_devices/boiler_object.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/smart_device_objects_u/simple_devices/light_object.dart';
import 'package:cbj_smart_device/features/smart_device/application/usecases/smart_device_objects_u/static_devices/blinds_object.dart';
import 'package:cbj_smart_device/features/smart_device/domain/entities/core_e/enums_e.dart';
import 'package:cbj_smart_device/features/smart_device/infrastructure/datasources/accounts_information_d/accounts_information_d.dart';
import 'package:cbj_smart_device/features/smart_device/infrastructure/datasources/local_db_d/local_db_d.dart';
import 'package:cbj_smart_device/features/smart_device/infrastructure/datasources/smart_server_d/protoc_as_dart/smart_connection.pbgrpc.dart';

class LocalDbR {
  LocalDbR() {
    _localDbD = LocalDbD();
  }

  LocalDbD? _localDbD;

  Future<List<SmartDeviceBaseAbstract>?> getListOfSmartDevices() async {
    List<SmartDeviceBaseAbstract>? smartDeviceBaseAbstractList =
        <SmartDeviceBaseAbstract>[];
    final String currentDeviceUuid = await MySingleton.getUuid();

    final Map<String, List<String?>>? deviceListMap =
        await _localDbD!.getListOfSmartDevices();
    if (deviceListMap == null) {
      return null;
    }
    for (final String deviceUuid in deviceListMap.keys) {
      final List<String?> values = deviceListMap[deviceUuid]!;
      final DeviceTypes deviceType =
          EnumHelper.stringToDeviceType(values.first!)!;

      switch (deviceType) {
        case DeviceTypes.light:
          final int? onOffPinNumber =
              values[1] == '' ? null : int.parse(values[1]!);
          print('Adding from local db light object');
          smartDeviceBaseAbstractList.add(LightObject(
            deviceUuid,
            'Light name missing',
            onOffPinNumber,
          ));
          break;
        case DeviceTypes.boiler:
          final int? boilerPinNumber =
              values[1] == '' ? null : int.parse(values[1]!);
          final int? boilerButtonPinNumber =
              values[2] == '' ? null : int.parse(values[2]!);
          print('Adding from local db boiler object');
          smartDeviceBaseAbstractList.add(BoilerObject(
            deviceUuid,
            'Boiler name missing',
            boilerPinNumber,
            boilerButtonPinNumber,
          ));
          break;
        case DeviceTypes.blinds:
          print('Adding from local db blind object');
          if (values.length < 7) {
            break;
          }

          final int? onOffPinNumber =
              values[1] == '' ? null : int.parse(values[1]!);
          final int? onOffButtonPinNumber =
              values[2] == '' ? null : int.parse(values[2]!);
          final int? blindsUpPin =
              values[3] == '' ? null : int.parse(values[3]!);
          final int? upButtonPinNumber =
              values[4] == '' ? null : int.parse(values[4]!);
          final int? blindsDownPin =
              values[5] == '' ? null : int.parse(values[5]!);
          final int? downButtonPinNumber =
              values[6] == '' ? null : int.parse(values[6]!);

          smartDeviceBaseAbstractList.add(BlindsObject(
            deviceUuid,
            'Blinds name is missing',
            onOffPinNumber,
            onOffButtonPinNumber,
            //  onOffButtonPinNumber
            blindsUpPin,
            //  blindsUpPin
            upButtonPinNumber,
            //  upButtonPinNumber
            blindsDownPin,
            //  blindsDownPin
            downButtonPinNumber, // downButtonPinNumber
          ));
          break;
        case DeviceTypes.button:
          final int? buttonPinNumber =
              values[1] == '' ? null : int.parse(values[1]!);
          print('Adding from local db button object');

          final Map<WhenToExecute, Map<SmartDeviceBase, List<DeviceActions>>>?
              buttonStatesAction = ButtonObject.buttonDefaultStateAction(
                  smartDeviceBaseAbstractList);

          smartDeviceBaseAbstractList.add(ButtonObject(
            deviceUuid,
            'Button name is missing',
            buttonPinNumber,
            buttonStatesAction: buttonStatesAction,
          ));
          break;
        case DeviceTypes.buttonWithLight:
          final int? buttonPinNumber =
              values[1] == '' ? null : int.parse(values[1]!);
          final int? buttonLightPinNumber =
              values[2] == '' ? null : int.parse(values[2]!);
          print('Adding from local db button object');

          final Map<WhenToExecute, Map<SmartDeviceBase, List<DeviceActions>>>?
              buttonStatesAction = ButtonObject.buttonDefaultStateAction(
                  smartDeviceBaseAbstractList);

          smartDeviceBaseAbstractList.add(ButtonWithLightObject(
            deviceUuid,
            'Button with light name is missing',
            buttonPinNumber,
            buttonLightPinNumber,
            buttonStatesAction: buttonStatesAction,
          ));
          break;
        default:
          print('Cannot add from local db, device type is not supported');
          break;
      }
    }
    if (smartDeviceBaseAbstractList.isEmpty) {
      smartDeviceBaseAbstractList = null;
    }
    return smartDeviceBaseAbstractList;
  }

  Future<FirebaseAccountsInformationD?> getListOfDatabaseInformation() async {
    final Map<String, String?>? firebaseAccountsInformationMap =
        await _localDbD!.getListOfDatabaseInformation();

    if (firebaseAccountsInformationMap == null) return null;

    final String fireBaseProjectId =
        firebaseAccountsInformationMap[AccountsInformationD.fireBaseProjectId]!;
    final String fireBaseApiKey =
        firebaseAccountsInformationMap[AccountsInformationD.fireBaseApiKey]!;
    final String userEmail =
        firebaseAccountsInformationMap[AccountsInformationD.userEmail]!;
    final String userPassword =
        firebaseAccountsInformationMap[AccountsInformationD.userPassword]!;

    final String homeId =
        firebaseAccountsInformationMap[AccountsInformationD.homeId]!;

    final FirebaseAccountsInformationD firebaseAccountsInformationD =
        FirebaseAccountsInformationD(
            fireBaseProjectId, fireBaseApiKey, userEmail, userPassword, homeId);

    return firebaseAccountsInformationD;
  }

  Future<void> saveAllDevices(
      List<SmartDeviceBaseAbstract> smartDevicesList) async {
    await _localDbD!.saveAllDevices(smartDevicesList);
    return;
  }

  void saveListOfDatabaseInformation(
      FirebaseAccountsInformationD firebaseAccountsInformationD) {
    _localDbD!.saveListOfDatabaseInformation(firebaseAccountsInformationD);
  }
}
