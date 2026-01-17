// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/screens/coming_soon/coming_soon_screen.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_screen.dart';
import 'package:streamit_laravel/screens/movie_list/movie_list_screen.dart';
import 'package:streamit_laravel/screens/profile/profile_screen.dart';
import 'package:streamit_laravel/screens/search/search_screen.dart';
import 'package:streamit_laravel/screens/tv_show/tvshow_list_screen.dart';

import '../../main.dart';
import '../../network/auth_apis.dart';
import '../../network/core_api.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage.dart' as storage;
import '../../video_players/model/vast_ad_response.dart';
import '../auth/sign_in/sign_in_screen.dart';
import '../home/home_screen.dart';
import '../search/search_controller.dart';
import '../unlocked_video/rented_list_screen.dart';
import '../video/video_list_screen.dart';
import 'components/menu.dart';

class DashboardController extends GetxController {
  RxBool isDrawerExpanded = false.obs;

  RxBool isFocusMovedToProfile = false.obs;
  RxBool isFirstItemInProfileFocused = false.obs;

  //Manage current screen
  RxList<BottomBarItem> bottomNavItems = [
    BottomBarItem(title: locale.value.home, icon: Icons.home_outlined, activeIcon: Icons.home, type: BottomItem.home, focusNode: FocusNode(), screen: SizedBox()),
    BottomBarItem(title: locale.value.search, icon: Icons.search_rounded, activeIcon: Icons.search_rounded, type: BottomItem.search, focusNode: FocusNode(), screen: SizedBox()),
    if (appConfigs.value.enableMovie) BottomBarItem(title: locale.value.movies, icon: Icons.movie_creation_outlined, activeIcon: Icons.movie_creation, type: BottomItem.movies, focusNode: FocusNode(), screen: SizedBox()),
    if (appConfigs.value.enableTvShow) BottomBarItem(title: locale.value.tVShows, icon: Icons.tv, activeIcon: Icons.tv, type: BottomItem.tvShows, focusNode: FocusNode(), screen: SizedBox()),
    if (appConfigs.value.enableVideo) BottomBarItem(title: locale.value.videos, icon: Icons.videocam_outlined, activeIcon: Icons.videocam_outlined, type: BottomItem.videos, focusNode: FocusNode(), screen: SizedBox()),
    BottomBarItem(title: locale.value.comingSoon, icon: Icons.campaign_outlined, activeIcon: Icons.campaign, type: BottomItem.comingsoon, focusNode: FocusNode(), screen: SizedBox()),
    if (isLoggedIn.value) BottomBarItem(title: locale.value.unlockedVideo, icon: Icons.lock_outline, activeIcon: Icons.lock_open_rounded, type: BottomItem.unlockedVideo, focusNode: FocusNode(), screen: SizedBox()),
    if (appConfigs.value.enableLiveTv) BottomBarItem(title: locale.value.liveTv, icon: Icons.live_tv_outlined, activeIcon: Icons.live_tv, type: BottomItem.livetv, focusNode: FocusNode(), screen: SizedBox()),
    BottomBarItem(title: locale.value.profile, icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, type: BottomItem.profile, focusNode: FocusNode(), screen: SizedBox()),
  ].obs;

  RxInt selectedBottomNavIndex = 0.obs;

  RxList<VastAd> vastAds = <VastAd>[].obs;

  @override
  void onInit() {
    getAppConfigurations();
    onBottomTabChange(BottomItem.home);
    super.onInit();
  }

  Future<void> onBottomTabChange(BottomItem type) async {
    int index = bottomNavItems.indexWhere((item) => item.type == type);

    if (index < 0 || index >= bottomNavItems.length) {
      log('Invalid index: $index');
      return;
    }

    try {
      isFocusMovedToProfile(isLoggedIn.value && type == BottomItem.profile);

      if ((bottomNavItems[selectedBottomNavIndex.value].type == BottomItem.home || bottomNavItems[selectedBottomNavIndex.value].type == BottomItem.movies) && type == BottomItem.search) {
        await handleSearchScreen();
      }
      hideKeyBoardWithoutContext();

      // Add or replace screen based on the tab type
      Widget newScreen;

      switch (type) {
        case BottomItem.home:
          newScreen = HomeScreen();
          break;
        case BottomItem.search:
          newScreen = SearchScreen();
          break;
        case BottomItem.movies:
          newScreen = MovieListScreen(title: locale.value.movies);
          break;
        case BottomItem.tvShows:
          newScreen = TvShowListScreen(title: locale.value.tVShows);
          break;
        case BottomItem.videos:
          newScreen = VideoListScreen();
          break;
        case BottomItem.comingsoon:
          newScreen = ComingSoonScreen();
          break;
        case BottomItem.unlockedVideo:
          newScreen = RentedListScreen();
          break;
        case BottomItem.livetv:
          newScreen = LiveTvScreen();
          break;
        case BottomItem.profile:
          newScreen = isLoggedIn.value ? ProfileScreen() : SignInScreen();
          break;
      }

      bottomNavItems[index].screen = newScreen;

      selectedBottomNavIndex(index);
    } catch (e) {
      log('onBottomTabChangeByIndex Err: $e');
    }
  }

  // Method to shrink the drawer
  void shrinkDrawer() {
    isDrawerExpanded.value = false;
  }

  // Method to expand the drawer
  void expandDrawer() {
    isDrawerExpanded.value = true;
  }

  Future<void> handleSearchScreen() async {
    SearchScreenController searchCont = getOrPutController(() => SearchScreenController());
    if (searchCont.searchTextCont.text.isNotEmpty) {
      searchCont.clearSearchField();
    }
  }

  Future<void> getAppConfigurations() async {
    if (!getBoolAsync(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE, defaultValue: false)) {
      await AuthServiceApis.getAppConfigurations(forceSync: !getBoolAsync(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE, defaultValue: false)).then(
        (value) {
          bottomNavItems[selectedBottomNavIndex.value];
        },
      ).onError((error, stackTrace) {
        toast(error.toString());
      });
    }
  }

  Future<void> getActiveVastAds() async {
    try {
      VastAdResponse? res = await CoreServiceApis.getVastAds();
      vastAds.value = res!.data ?? [];
    } catch (e) {
      log('getActiveVastAds Err: $e');
    }
  }

  @override
  void onReady() {
    if (Get.context != null) {
      View.of(Get.context!).platformDispatcher.onPlatformBrightnessChanged = () {
        WidgetsBinding.instance.handlePlatformBrightnessChanged();
        try {
          final getThemeFromLocal = storage.getValueFromLocal(SettingsLocalConst.THEME_MODE);
          if (getThemeFromLocal is int) {
            toggleThemeMode(themeId: getThemeFromLocal);
          }
        } catch (e) {
          log('getThemeFromLocal from cache E: $e');
        }
      };
      getActiveVastAds();
    }
    super.onReady();
  }
}
