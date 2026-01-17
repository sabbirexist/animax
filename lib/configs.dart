// ignore_for_file: constant_identifier_names

import 'package:country_picker/country_picker.dart';

const APP_NAME = 'Streamit';
const APP_LOGO_URL = '$DOMAIN_URL/img/logo/mini_logo.png';
const DEFAULT_LANGUAGE = 'en';
const DASHBOARD_AUTO_SLIDER_SECOND = 6000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_VIDEO = 30000;
const CUSTOM_AD_AUTO_SLIDER_SECOND_IMAGE = 30000;
const LIVE_AUTO_SLIDER_SECOND = 5;

const API_VERSION = 2;

///DO NOT ADD SLASH HERE
const DOMAIN_URL = "";

const BASE_URL = '$DOMAIN_URL/api/';

const APP_APPSTORE_URL = '';

const TERMS_CONDITION_URL = '$DOMAIN_URL/page/terms-conditions';
const PRIVACY_POLICY_URL = '$DOMAIN_URL/page/privacy-policy';

//region RazorPay
const String commonSupportedCurrency = 'INR';
//endregion

//region  PAYSTACK
const String payStackCurrency = "NGN";
//endregion

// PAYPAl
const String payPalSupportedCurrency = 'USD';
//endregion

//region defaultCountry
Country get defaultCountry => Country(
      phoneCode: '91',
      countryCode: 'IN',
      e164Sc: 91,
      geographic: true,
      level: 1,
      name: 'India',
      example: '23456789',
      displayName: 'India (IN) [+91]',
      displayNameNoCountryCode: 'India (IN)',
      e164Key: '91-IN-0',
      fullExampleWithPlusSign: '+919123456789',
    );
//endregion