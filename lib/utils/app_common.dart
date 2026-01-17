import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pod_player/pod_player.dart';
import 'package:streamit_laravel/components/device_not_supported_widget.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/screens/auth/sign_in/sign_in_screen.dart';
import 'package:streamit_laravel/screens/dashboard/dashboard_controller.dart';
import 'package:streamit_laravel/screens/profile/watching_profile/model/profile_watching_model.dart';

import '../configs.dart';
import '../main.dart';
import '../screens/auth/model/about_page_res.dart';
import '../screens/auth/model/app_configuration_res.dart';
import '../screens/auth/model/login_response.dart';
import '../screens/setting/account_setting/model/account_setting_response.dart';
import '../screens/subscription/model/subscription_plan_model.dart';
import 'colors.dart';
import 'common_base.dart';
import 'constants.dart';

String appPackageName = 'com.iqonic.streamitlaraveltv';

Future<bool> get isIqonicProduct async => await getPackageName() == appPackageName;

RxString selectedLanguageCode = DEFAULT_LANGUAGE.obs;
RxBool isLoggedIn = false.obs;
RxBool is18Plus = false.obs;
Rx<UserData> loginUserData = UserData(planDetails: SubscriptionPlanModel()).obs;
RxList<AboutDataModel> appPageList = <AboutDataModel>[].obs;
RxBool isDarkMode = false.obs;
RxString tempOTP = "".obs;
Rx<DeviceInfoPlugin> deviceInfo = DeviceInfoPlugin().obs;
RxBool adsLoader = false.obs;
RxList<WatchingProfileModel> accountProfiles = RxList();
Rx<WatchingProfileModel> selectedAccountProfile = WatchingProfileModel().obs;
RxInt profileId = 0.obs;
RxBool isSupportedDevice = true.obs;
Rx<SubscriptionPlanModel> currentSubscription = SubscriptionPlanModel().obs;
RxBool isInternetAvailable = true.obs;
RxBool isRTL = false.obs;
Rx<YourDevice> yourDevice = YourDevice().obs;
RxBool isPipModeOn = false.obs;

ListAnimationType commonListAnimationType = ListAnimationType.None;

Rx<Currency> appCurrency = Currency().obs;
Rx<ConfigurationResponse> appConfigs = ConfigurationResponse(
  vendorAppUrl: VendorAppUrl(),
  razorPay: RazorPay(),
  stripePay: StripePay(),
  payStackPay: PaystackPay(),
  paypalPay: PaypalPay(),
  flutterWavePay: FlutterwavePay(),
  currency: Currency(),
).obs;

// Currency position common
bool get isCurrencyPositionLeft => appCurrency.value.currencyPosition == CurrencyPosition.CURRENCY_POSITION_LEFT;

bool get isCurrencyPositionRight => appCurrency.value.currencyPosition == CurrencyPosition.CURRENCY_POSITION_RIGHT;

bool get isCurrencyPositionLeftWithSpace => appCurrency.value.currencyPosition == CurrencyPosition.CURRENCY_POSITION_LEFT_WITH_SPACE;

bool get isCurrencyPositionRightWithSpace => appCurrency.value.currencyPosition == CurrencyPosition.CURRENCY_POSITION_RIGHT_WITH_SPACE;
//endregion

String get appNameTopic => APP_NAME.toLowerCase().replaceAll(' ', '_');

List top10Icons = [
  Assets.top10IconIcOne,
  Assets.top10IconIcTwo,
  Assets.top10IconIcThree,
  Assets.top10IconIcFour,
  Assets.top10IconIcFive,
  Assets.top10IconIcSix,
  Assets.top10IconIcSeven,
  Assets.top10IconIcEight,
  Assets.top10IconIcNine,
  Assets.top10IconIcTen,
];

String convertDate(String dateString) {
  if (dateString != "") {
    DateTime date = DateTime.parse(dateString);
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }
  return "";
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

ReadMoreText readMoreTextWidget(
  String data, {
  Color? colorClickableText,
  int trimLength = 250,
  int trimLines = 3,
  TrimMode trimMode = TrimMode.Line,
  TextAlign? textAlign,
  TextDirection? textDirection,
  double? textScaleFactor,
  String? semanticsLabel,
  TextStyle? style,
}) {
  return ReadMoreText(
    parseHtmlString(data),
    trimMode: trimMode,
    style: style ?? commonSecondaryTextStyle(color: descriptionTextColor),
    textAlign: textAlign,
    trimLength: trimLength,
    colorClickableText: colorClickableText,
    semanticsLabel: semanticsLabel,
    trimExpandedText: locale.value.readLess.prefixText(value: ' '),
    trimCollapsedText: locale.value.readMore,
    trimLines: trimLines,
    textScaleFactor: textScaleFactor,
  );
}

Border focusBorder(bool condition) {
  return Border.all(color: condition ? white : Colors.transparent, width: condition ? 3 : 0);
}

void showSubscriptionDialog({required String title, required String msg, Color? color}) {
  RxBool hasFocus = true.obs;
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: boldTextStyle()),
        content: Text(
          msg,
          style: secondaryTextStyle(),
        ),
        actions: [
          Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
                  Get.back();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            canRequestFocus: true,
            autofocus: true,
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: color ?? appColorPrimary,
                  border: focusBorder(hasFocus.value),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(locale.value.ok, style: primaryTextStyle()),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Widget viewAllWidget({
  required String label,
  Widget? iconButton,
  Color? labelColor,
  int? labelSize,
  void Function()? onButtonPressed,
  Icon? icon,
  IconData? iconData,
  double? iconSize,
  Color? iconColor,
  bool showViewAll = true,
}) {
  return Row(
    children: [
      Text(
        label,
        style: commonPrimaryTextStyle(size: labelSize ?? 18, color: labelColor ?? primaryTextColor),
      ).expand(),
      if (showViewAll)
        iconButton ??
            InkWell(
              onTap: onButtonPressed,
              splashColor: appColorPrimary.withValues(alpha: 0.5),
              highlightColor: Colors.transparent,
              child: Icon(
                iconData ?? Icons.chevron_right_rounded,
                size: iconSize ?? 20,
                color: iconColor ?? white,
              ),
            ),
    ],
  ).paddingSymmetric(horizontal: 16, vertical: 16);
}

String getEndPoint({required String endPoint, int? perPages, int? page, List<String>? params}) {
  String perPage = "?per_page=$perPages";
  String pages = "&page=$page";

  if (page != null && params.validate().isEmpty) {
    return "$endPoint$perPage$pages";
  } else if (page != null && params.validate().isNotEmpty) {
    return "$endPoint$perPage$pages&${params.validate().join('&')}";
  } else if (page == null && params != null && params.isNotEmpty) {
    return "$endPoint?${params.join('&')}";
  }
  return endPoint;
}

void doIfLogin({required VoidCallback onLoggedIn}) {
  if (isLoggedIn.value) {
    onLoggedIn.call();
  } else {
    LiveStream().emit(podPlayerPauseKey);
    Get.to(() => SignInScreen(), arguments: false);
  }
}

void onSubscriptionLoginCheck({
  required VoidCallback callBack,
  int planId = 0,
  int planLevel = 0,
  required String videoAccess,
  bool isFromSubscribeCard = false,
  String? title,
}) {
  LiveStream().emit(podPlayerPauseKey);
  if (isLoggedIn.value) {
    if (planId == 0 && planLevel == 0 && isFromSubscribeCard) {
      //This is to launch subscription screen when not to navigate from origin
      showSubscriptionDialog(title: locale.value.subscriptionRequired, msg: locale.value.pleaseSubscribeOrUpgrade);
    } else {
      if (videoAccess == MovieAccess.freeAccess && isSupportedDevice.value) {
        callBack.call();
      } else if (currentSubscription.value.level >= planLevel && isSupportedDevice.value) {
        callBack.call();
      } else {
        if (!isSupportedDevice.value || (videoAccess != MovieAccess.freeAccess && currentSubscription.value.level < planLevel)) {
          if (!isSupportedDevice.value) {
            showInDialog(
              Get.context!,
              backgroundColor: canvasColor,
              insetPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(),
              builder: (p0) {
                return DeviceNotSupportedComponent(title: title.validate());
              },
            );
          } else {
            showSubscriptionDialog(title: locale.value.subscriptionRequired, msg: locale.value.pleaseSubscribeOrUpgrade);
          }
        } else {
          callBack.call();
        }
      }
    }
  } else {
    doIfLogin(onLoggedIn: callBack);
  }
}

List<(String, IconData, Color)> getSupportedDeviceText({
  bool isMobileSupported = false,
  bool isDesktopSupported = false,
  bool isTabletSupported = false,
}) {
  List<(String, IconData, Color)> supportedDeviceText = [];

  supportedDeviceText.add(
    (
      '${locale.value.mobile}${isMobileSupported ? locale.value.supported : locale.value.notSupported}',
      isMobileSupported ? Icons.check_circle_outline_rounded : Icons.clear,
      isMobileSupported ? discountColor : redColor,
    ),
  );
  supportedDeviceText.add((
    '${locale.value.laptop}${isDesktopSupported ? locale.value.supported : locale.value.notSupported}',
    isDesktopSupported ? Icons.check_circle_outline_rounded : Icons.clear,
    isDesktopSupported ? discountColor : redColor,
  ));
  supportedDeviceText.add(
    (
      '${locale.value.tablet.suffixText(value: ' ')}${isTabletSupported ? locale.value.supported : locale.value.notSupported}',
      isTabletSupported ? Icons.check_circle_outline_rounded : Icons.clear,
      isTabletSupported ? discountColor : redColor,
    ),
  );

  return supportedDeviceText;
}

(String, String) getDownloadQuality(PlanLimit? planLimit) {
  String notSupportedText = '';
  String supportedText = '';
  if (planLimit != null) {
    if (planLimit.four80Pixel.getBoolInt()) {
      supportedText += '480P';
    } else {
      notSupportedText += '480P';
    }
    if (planLimit.seven20p.getBoolInt()) {
      supportedText += '780P';
    } else {
      notSupportedText += '780P';
    }
    if (planLimit.one080p.getBoolInt()) {
      supportedText += '1080P';
    } else {
      notSupportedText += '1080P';
    }
    if (planLimit.oneFourFour0Pixel.getBoolInt()) {
      supportedText += '1440P';
    } else {
      notSupportedText += '1440P';
    }
    if (planLimit.twoKPixel.getBoolInt()) {
      supportedText += '2K';
    } else {
      notSupportedText += '2K';
    }
    if (planLimit.fourKPixel.getBoolInt()) {
      supportedText += '4K';
    } else {
      notSupportedText += '4K';
    }
    if (planLimit.eightKPixel.getBoolInt()) {
      supportedText += '8k';
    } else {
      notSupportedText += '8k';
    }
  }

  RegExp regex = RegExp(r"(?<=P|K)");
  List<String> notSupportedParts = [];
  List<String> supportedParts = [];
  if (notSupportedText.isNotEmpty) {
    notSupportedParts = notSupportedText.split(regex);
  }
  if (supportedText.isNotEmpty) supportedParts = supportedText.split(regex);

  return (supportedParts.join('/'), notSupportedParts.join('/'));
}

String getPageIcon(String slug) {
  switch (slug) {
    case AppPages.privacyPolicy:
      {
        return Assets.iconsIcPrivacy;
      }
    case AppPages.termsAndCondition:
      {
        return Assets.iconsIcTc;
      }
    case AppPages.helpAndSupport:
      {
        return Assets.iconsIcFaq;
      }
    case AppPages.refundAndCancellation:
      {
        return Assets.iconsIcRefund;
      }
    case AppPages.dataDeletion:
      {
        return Assets.iconsIcDataDelete;
      }
    case AppPages.aboutUs:
      {
        return Assets.iconsIcAboutUs;
      }
    default:
      return Assets.iconsIcPage;
  }
}

Future<void> launchUrlCustomURL(String? url) async {
  if (url.validate().isNotEmpty) {
    await custom_tabs.launchUrl(
      Uri.parse(url.validate()),
      customTabsOptions: custom_tabs.CustomTabsOptions(
        colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(toolbarColor: appColorPrimary),
        animations: custom_tabs.CustomTabsSystemAnimations.slideIn(),
        urlBarHidingEnabled: true,
        shareState: custom_tabs.CustomTabsShareState.on,
        browser: custom_tabs.CustomTabsBrowserConfiguration(
          fallbackCustomTabs: [
            'org.mozilla.firefox',
            'com.microsoft.emmx',
          ],
          headers: {'key': 'value'},
        ),
      ),
      safariVCOptions: custom_tabs.SafariViewControllerOptions(
        barCollapsingEnabled: true,
        dismissButtonStyle: custom_tabs.SafariViewControllerDismissButtonStyle.close,
        entersReaderIfAvailable: false,
        preferredControlTintColor: appScreenBackgroundDark,
        preferredBarTintColor: appColorPrimary,
      ),
    );
  }
}

Future<void> checkApiCallIsWithinTimeSpan({
  bool forceSync = false,
  required VoidCallback callback,
  required String sharePreferencesKey,
  Duration? duration,
}) async {
  DateTime currentTimeStamp = DateTime.timestamp();
  DateTime lastSyncedTimeStamp = DateTime.fromMillisecondsSinceEpoch(getIntAsync(sharePreferencesKey, defaultValue: 0));
  DateTime fiveMinutesLater = lastSyncedTimeStamp.add(duration ?? const Duration(minutes: 5));

  if (forceSync || currentTimeStamp.isAfter(fiveMinutesLater)) {
    callback.call();
  } else {
    log('$sharePreferencesKey was synced recently');
  }
}

DashboardController getDashboardController() {
  return Get.put(DashboardController());
}

bool isComingSoon(String releaseDate) {
  DateTime now = DateTime.now();
  DateTime releaseDateParsed = DateFormat(DateFormatConst.yyyy_MM_dd).parse(releaseDate);
  return releaseDateParsed.isAfter(now);
}

bool checkQualitySupported({required String quality, required int requirePlanLevel}) {
  bool supported = false;
  PlanLimit currentPlanLimit = PlanLimit();
  int index = -1;
  index = currentSubscription.value.planType.indexWhere((element) => (element.slug == SubscriptionTitle.downloadStatus || element.limitationSlug == SubscriptionTitle.downloadStatus));
  if (requirePlanLevel == 0) {
    supported = true;
  } else {
    if (index > -1) {
      currentPlanLimit = currentSubscription.value.planType[index].limit;

      switch (quality) {
        case "480p":
          supported = currentPlanLimit.four80Pixel.getBoolInt();
          break;
        case "720p":
          supported = currentPlanLimit.seven20p.getBoolInt();
          break;
        case "1080p":
          supported = currentPlanLimit.one080p.getBoolInt();
          break;
        case "1440p":
          supported = currentPlanLimit.oneFourFour0Pixel.getBoolInt();
          break;
        case "2K":
          supported = currentPlanLimit.twoKPixel.getBoolInt();
          break;
        case "4K":
          supported = currentPlanLimit.fourKPixel.getBoolInt();
          break;
        case "8K":
          supported = currentPlanLimit.eightKPixel.getBoolInt();
          break;
        default:
          break;
      }
    }
  }

  return supported;
}

String movieEmbedCode(String iframeHtml, {bool autoplay = false}) {
  final uriRegex = RegExp(r'src="([^"]+)"');
  final match = uriRegex.firstMatch(iframeHtml);
  if (match == null) {
    return buildHtmlCodeForWebViewPlay(iframeHtml, autoplay: autoplay);
  }

  String url = match.group(1)!;
  final isYouTube = url.contains("youtube.com");

  if (!isYouTube) {
    return buildHtmlCodeForWebViewPlay(iframeHtml, autoplay: autoplay);
  }

  // Append required params
  Uri uri = Uri.parse(url);
  Map<String, String> params = Map.from(uri.queryParameters);
  params['enablejsapi'] = '1';
  params['autoplay'] = '1';
  params['mute'] = autoplay ? '1' : '0'; // mute must be 1 for autoplay to work

  final Uri newUri = uri.replace(queryParameters: params);

  return '''
  <!DOCTYPE html>
  <html>
    <head>
      <style>
        html, body {
          margin: 0;
          padding: 0;
          height: 100%;
          background-color: black;
        }
        iframe {
          width: 100%;
          height: 100%;
          border: none;
          display: block;
        }
      </style>
    </head>
    <body>
      <iframe id="player"
        src="${newUri.toString()}"
        allow="autoplay; encrypted-media"
        allowfullscreen>
      </iframe>

      <script>
        var tag = document.createElement('script');
        tag.src = "https://www.youtube.com/iframe_api";
        var firstScriptTag = document.getElementsByTagName('script')[0];
        firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

        var player;
        var intervalId;

        function onYouTubeIframeAPIReady() {
          player = new YT.Player('player', {
            events: {
              'onReady': onPlayerReady,
              'onStateChange': onPlayerStateChange
            }
          });
        }

        function onPlayerReady(event) {
          try {
            event.target.playVideo();
          } catch (e) {
            console.error('Autoplay error:', e);
          }

          if (window.VideoChannel && VideoChannel.postMessage) {
            VideoChannel.postMessage("ready");
          }
        }

        function onPlayerStateChange(event) {
          if (event.data == YT.PlayerState.PLAYING) {
            VideoChannel.postMessage("playing");
            if (intervalId) clearInterval(intervalId);
            intervalId = setInterval(function() {
              var duration = player.getDuration();
              var currentTime = player.getCurrentTime();
              VideoChannel.postMessage(JSON.stringify({
                event: "timeUpdate",
                currentTime: currentTime,
                duration: duration
              }));
            }, 1000);
          } else if (event.data == YT.PlayerState.ENDED) {
            VideoChannel.postMessage("ended");
            if (intervalId) clearInterval(intervalId);
          } else if (event.data == YT.PlayerState.PAUSED) {
            VideoChannel.postMessage("paused");
            if (intervalId) clearInterval(intervalId);
          }
        }
      </script>
    </body>
  </html>
  ''';
}

String buildHtmlCodeForWebViewPlay(String url, {bool autoplay = false}) => '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link href="https://vjs.zencdn.net/8.9.0/video-js.css" rel="stylesheet" />
  <style>
    html, body {
      margin: 0;
      padding: 0;
      height: 100%;
      background-color: #000;
    }
    .video-js {
      width: 100%;
      height: 100%;
    }
    .vjs-quality-selector {
      position: absolute;
      top: 10px;
      right: 10px;
      z-index: 1000;
    }
    .vjs-quality-selector select {
      background: rgba(0, 0, 0, 0.8);
      color: white;
      border: 1px solid #666;
      padding: 5px;
      border-radius: 3px;
      font-size: 12px;
    }
    .vjs-subtitle-selector {
      position: absolute;
      top: 40px;
      right: 10px;
      z-index: 1000;
    }
    .vjs-subtitle-selector select {
      background: rgba(0, 0, 0, 0.8);
      color: white;
      border: 1px solid #666;
      padding: 5px;
      border-radius: 3px;
      font-size: 12px;
    }
  </style>
</head>
<body>

<video
  id="videoPlayer"
  class="video-js vjs-default-skin"
  controls
  ${autoplay ? 'autoplay' : ''}
  muted
  playsinline
  data-setup='{"autoplay": ${autoplay ? 'true' : 'false'}, "muted": true}'>
  <source src="$url" type="video/mp4" />
</video>

<div class="vjs-quality-selector" id="qualitySelector" style="display: none;">
  <select id="qualitySelect">
    <option value="auto">Auto</option>
  </select>
</div>

<div class="vjs-subtitle-selector" id="subtitleSelector" style="display: none;">
  <select id="subtitleSelect">
    <option value="-1">Off</option>
  </select>
</div>

<script src="https://vjs.zencdn.net/8.9.0/video.min.js"></script>
<script>
  let player;
  let availableQualities = [];
  let availableSubtitles = [];
  let currentQuality = 'auto';
  let currentSubtitle = -1;

  document.addEventListener('DOMContentLoaded', function () {
    player = videojs('videoPlayer');

    player.ready(function () {
      try {
        player.play().catch(function(error) {
          console.error("Autoplay blocked:", error.message);
          if (window.VideoChannel && VideoChannel.postMessage) {
            VideoChannel.postMessage("autoplay_error: " + error.message);
          }
        });
      } catch (e) {
        console.error("Error starting video:", e);
      }
    });

    if (window.VideoChannel && VideoChannel.postMessage) {
      VideoChannel.postMessage("ready");
    }

    var intervalId;

    player.on('play', function () {
      VideoChannel.postMessage("playing");
      clearInterval(intervalId);
      intervalId = setInterval(function () {
        const current = player.currentTime();
        const duration = player.duration();
        VideoChannel.postMessage(JSON.stringify({
          event: "timeUpdate",
          currentTime: current,
          duration: duration
        }));
      }, 1000);
    });

    player.on('pause', function () {
      VideoChannel.postMessage("paused");
      clearInterval(intervalId);
    });

    player.on('ended', function () {
      VideoChannel.postMessage("ended");
      clearInterval(intervalId);
    });

    player.on('seeking', function () {
      VideoChannel.postMessage("seeking");
    });

    player.on('seeked', function () {
      VideoChannel.postMessage("seeked");
    });

    // Listen for messages from Flutter
    window.addEventListener('message', function(event) {
      try {
        const data = event.data;
        
        if (data.qualities && data.qualities.length > 0) {
          availableQualities = data.qualities;
          setupQualitySelector();
        }
        
        if (data.subtitles && data.subtitles.length > 0) {
          availableSubtitles = data.subtitles;
          setupSubtitleSelector();
        }
        
        if (data.currentQuality) {
          currentQuality = data.currentQuality;
          updateQualitySelector();
        }
        
        if (data.currentSubtitle !== undefined) {
          currentSubtitle = data.currentSubtitle;
          updateSubtitleSelector();
        }
      } catch (e) {
        console.error('Error processing message:', e);
      }
    });
  });

  function setupQualitySelector() {
    const qualitySelector = document.getElementById('qualitySelector');
    const qualitySelect = document.getElementById('qualitySelect');
    
    // Clear existing options except "Auto"
    qualitySelect.innerHTML = '<option value="auto">Auto</option>';
    
    availableQualities.forEach(quality => {
      const option = document.createElement('option');
      option.value = quality.quality;
      option.textContent = quality.quality;
      option.setAttribute('data-url', quality.url);
      option.setAttribute('data-type', quality.type);
      qualitySelect.appendChild(option);
    });
    
    qualitySelector.style.display = 'block';
    
    qualitySelect.addEventListener('change', function() {
      const selectedQuality = this.value;
      if (selectedQuality !== currentQuality) {
        changeQuality(selectedQuality);
      }
    });
  }

  function setupSubtitleSelector() {
    const subtitleSelector = document.getElementById('subtitleSelector');
    const subtitleSelect = document.getElementById('subtitleSelect');
    
    // Clear existing options except "Off"
    subtitleSelect.innerHTML = '<option value="-1">Off</option>';
    
    availableSubtitles.forEach(subtitle => {
      const option = document.createElement('option');
      option.value = subtitle.id;
      option.textContent = subtitle.language;
      option.setAttribute('data-url', subtitle.subtitleFileURL);
      subtitleSelect.appendChild(option);
    });
    
    subtitleSelector.style.display = 'block';
    
    subtitleSelect.addEventListener('change', function() {
      const selectedSubtitleId = parseInt(this.value);
      if (selectedSubtitleId !== currentSubtitle) {
        changeSubtitle(selectedSubtitleId);
      }
    });
  }

  function changeQuality(quality) {
    const qualityData = availableQualities.find(q => q.quality === quality);
    if (qualityData) {
      // Store current position
      const currentTime = player.currentTime();
      const wasPlaying = !player.paused();
      
      // Change video source
      player.src({
        type: 'video/mp4',
        src: qualityData.url
      });
      
      player.ready(function() {
        // Restore position and playback state
        player.currentTime(currentTime);
        if (wasPlaying) {
          player.play();
        }
        
        // Notify Flutter about quality change
        VideoChannel.postMessage(JSON.stringify({
          event: "qualityChanged",
          quality: quality
        }));
      });
      
      currentQuality = quality;
    }
  }

  function changeSubtitle(subtitleId) {
    if (subtitleId === -1) {
      // Turn off subtitles
      const tracks = player.textTracks();
      for (let i = 0; i < tracks.length; i++) {
        tracks[i].mode = 'disabled';
      }
    } else {
      const subtitleData = availableSubtitles.find(s => s.id === subtitleId);
      if (subtitleData) {
        // Remove existing subtitle tracks
        const tracks = player.textTracks();
        for (let i = tracks.length - 1; i >= 0; i--) {
          player.removeRemoteTextTrack(tracks[i]);
        }
        
        // Add new subtitle track
        player.addRemoteTextTrack({
          kind: 'subtitles',
          src: subtitleData.subtitleFileURL,
          srclang: subtitleData.language,
          label: subtitleData.language,
          default: subtitleData.isDefaultLanguage === 1
        }, false);
        
        // Enable the subtitle track
        const newTracks = player.textTracks();
        for (let i = 0; i < newTracks.length; i++) {
          if (newTracks[i].label === subtitleData.language) {
            newTracks[i].mode = 'showing';
            break;
          }
        }
      }
    }
    
    // Notify Flutter about subtitle change
    VideoChannel.postMessage(JSON.stringify({
      event: "subtitleChanged",
      subtitleId: subtitleId
    }));
    
    currentSubtitle = subtitleId;
  }

  function updateQualitySelector() {
    const qualitySelect = document.getElementById('qualitySelect');
    if (qualitySelect) {
      qualitySelect.value = currentQuality;
    }
  }

  function updateSubtitleSelector() {
    const subtitleSelect = document.getElementById('subtitleSelect');
    if (subtitleSelect) {
      subtitleSelect.value = currentSubtitle;
    }
  }
</script>

</body>
</html>
''';

String getTypeForContinueWatch({required String type}) {
  String videoType = "";
  dynamic videoTypeMap = {
    "movie": VideoType.movie,
    "video": VideoType.video,
    "livetv": VideoType.liveTv,
    'tvshow': VideoType.tvshow,
    'episode': VideoType.tvshow,
  };
  videoType = videoTypeMap[type] ?? '';
  return videoType;
}

Duration getWatchedTimeInDuration(String watchedTime) {
  final parts = watchedTime.split(':');
  final hours = int.parse(parts[0]);
  final minutes = int.parse(parts[1]);
  final seconds = int.parse(parts[2]);
  return Duration(hours: hours, minutes: minutes, seconds: seconds);
}

PlayVideoFrom getVideoPlatform({required String type, required String videoURL}) {
  String validatedUrl = videoURL.trim();
  validatedUrl = validatedUrl.replaceAll("'", "").replaceAll('"', "");

  final Map<String, String> defaultHeaders = {
    'Referer': DOMAIN_URL,
    'User-Agent': 'Mozilla/5.0 (Linux; Android 11; TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
    'Accept': '*/*',
    'Connection': 'keep-alive',
  };

  final Map<String, String> hlsHeaders = {
    'Referer': DOMAIN_URL,
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
  };

  final Map<String, String> mp4Headers = {
    'User-Agent': 'Mozilla/5.0 (Linux; Android 11; TV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36',
    'Accept': 'video/mp4,video/*,*/*',
    'Accept-Encoding': 'identity',
    'Range': 'bytes=0-',
  };

  try {
    Map<String, String> headersToUse = defaultHeaders;

    if ((type.toLowerCase() == PlayerTypes.local.toLowerCase() || type.toLowerCase() == PlayerTypes.url.toLowerCase()) &&
        validatedUrl.toLowerCase().contains('.mp4') &&
        validatedUrl.startsWith('https://')) {
      headersToUse = mp4Headers;
      log("+-+-+-+-+-+-+-+-+-Using MP4 headers for HTTPS video");
    }

    Map<String, PlayVideoFrom> videoTypeMap = {
      PlayerTypes.hls: PlayVideoFrom.network(validatedUrl, httpHeaders: hlsHeaders),
      PlayerTypes.url: PlayVideoFrom.network(validatedUrl, httpHeaders: headersToUse),
      PlayerTypes.x265: PlayVideoFrom.network(validatedUrl, httpHeaders: defaultHeaders),
      PlayerTypes.local: PlayVideoFrom.network(validatedUrl, httpHeaders: headersToUse),
      PlayerTypes.file: PlayVideoFrom.file(File(validatedUrl)),
      PlayerTypes.youtube: PlayVideoFrom.youtube(validatedUrl, live: validatedUrl.contains('/live/')),
    };

    final result = videoTypeMap[type] ?? PlayVideoFrom.network(validatedUrl, httpHeaders: headersToUse);
    log("+-+-+-+-+-+-+-+-+-getVideoPlatform result: ${result.runtimeType} with headers for type '$type'");
    return result;
  } catch (e) {
    log("Error in getVideoPlatform: ${e.toString()}");
    return PlayVideoFrom.network(validatedUrl);
  }
}
