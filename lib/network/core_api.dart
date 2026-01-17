import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/network_utils.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/coming_soon/model/coming_soon_response.dart';
import 'package:streamit_laravel/screens/genres/model/genres_model.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/screens/live_tv/live_tv_details/model/live_tv_details_response.dart';
import 'package:streamit_laravel/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:streamit_laravel/screens/profile/model/profile_detail_resp.dart';
import 'package:streamit_laravel/screens/profile/watching_profile/model/profile_watching_model.dart';
import 'package:streamit_laravel/screens/search/model/search_response.dart';
import 'package:streamit_laravel/screens/setting/model/faq_model.dart';
import 'package:streamit_laravel/screens/subscription/model/subscription_model.dart';
import 'package:streamit_laravel/screens/video/video_details/model/video_details_resp.dart';
import 'package:streamit_laravel/screens/watch_list/model/watch_list_resp.dart';
import 'package:streamit_laravel/utils/app_common.dart';
import 'package:streamit_laravel/utils/constants.dart';

import '../main.dart';
import '../models/base_response_model.dart';
import '../screens/auth/model/about_page_res.dart';
import '../screens/auth/model/tv_session_response.dart';
import '../screens/channel_list/model/channel_list_model.dart';
import '../screens/movie_details/model/movie_details_resp.dart';
import '../screens/person/model/person_model.dart';
import '../screens/person/person_list/model/person_list_resp.dart';
import '../screens/unlocked_video/model/rented_content_model.dart';
import '../screens/search/model/search_list_model.dart';
import '../screens/setting/account_setting/model/account_setting_response.dart';
import '../screens/subscription/model/subscription_plan_model.dart';
import '../screens/tv_show/episode/models/episode_model.dart';
import '../screens/tv_show/models/tv_show_model.dart';
import '../utils/api_end_points.dart';
import '../utils/common_base.dart';
import '../video_players/model/vast_ad_response.dart';
import '../video_players/model/video_model.dart';

class CoreServiceApis {
  static Future<DashboardDetailResponse> getDashboard() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');

    DashboardDetailResponse dashboardDetailsResp = DashboardDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.dashboardDetails, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
    cachedDashboardDetailResponse = dashboardDetailsResp;
    setValue(SharedPreferenceConst.CACHE_DASHBOARD, dashboardDetailsResp.toJson());

    return dashboardDetailsResp;
  }

  static Future<DashboardDetailResponse> getDashboardDetailOtherData() async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');

    DashboardDetailResponse dashboardDetailsResp = DashboardDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.dashboardDetailsOtherData, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
    if (cachedDashboardDetailResponse != null) {
      DashboardDetailResponse res = cachedDashboardDetailResponse ?? DashboardDetailResponse(data: DashboardModel());
      cachedDashboardDetailResponse = dashboardDetailsResp;

      cachedDashboardDetailResponse?.data.slider = res.data.slider;
      cachedDashboardDetailResponse?.data.continueWatch = res.data.continueWatch;
      cachedDashboardDetailResponse?.data.top10List = res.data.top10List;
    }
    setValue(SharedPreferenceConst.CACHE_DASHBOARD, dashboardDetailsResp.toJson());

    return dashboardDetailsResp;
  }

  static Future<LiveChannelDashboardResponse> getLiveDashboard() async {
    LiveChannelDashboardResponse liveChannelDashboardResp = LiveChannelDashboardResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.liveTvDashboard,
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
    cachedLiveTvDashboard = liveChannelDashboardResp;
    setValue(SharedPreferenceConst.CACHE_LIVE_TV_DASHBOARD, liveChannelDashboardResp.toJson());
    return liveChannelDashboardResp;
  }

  // Original Search Details
  static Future<SearchResponse> getSearchDetails({required String search}) async {
    List<String> params = [];
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');
    if (search.isNotEmpty) params.add('search=$search');
    return SearchResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.getSearchMovie, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  // Original Search List
  static Future<SearchListResponse> getSearchList() async {
    List<String> params = [];
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return SearchListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.searchList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  //Profile Details Screen
  static Future<ProfileDetailResponse> getProfileDet() async {
    List<String> params = [];
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    ProfileDetailResponse profileDetailResp = ProfileDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.profileDetails,
            params: params,
          ),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
    cachedProfileDetails = profileDetailResp;
    setValue(SharedPreferenceConst.CACHE_PROFILE_DETAIL, profileDetailResp.toJson());
    return profileDetailResp;
  }

  //Account Setting Screen
  static Future<AccountSettingResponse> getAccountSettingsResponse({required String deviceId}) async {
    String id = deviceId.isNotEmpty ? "?device_id=$deviceId" : "";
    return AccountSettingResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.accountSetting}$id",
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  //Live Show details
  static Future<LiveShowDetailResponse> getLiveShowDetails({required int channelId, int userId = -1}) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');

    params.add('channel_id=$channelId');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return LiveShowDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.liveTvDetails, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  //Movie Details
  static Future<MovieDetailResponse> getMovieDetails({required int movieId, int userId = -1}) async {
    List<String> params = [];
    params.add('movie_id=$movieId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return MovieDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.movieDetails, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
  }

  //Video Details
  static Future<VideoDetailResponse> getVideoDetails({required int movieId, int userId = -1}) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');

    params.add('video_id=$movieId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return VideoDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.videoDetails, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  //Episode Details
  static Future<EpisodeModel> episodeDetails({
    required int episodeId,
    int userId = -1,
    required int tvShowId,
    required int seasonId,
  }) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    params.add('device_id=${yourDevice.value.deviceId}');

    params.add('episode_id=$episodeId');
    if (tvShowId > -1) params.add('tv_show=$tvShowId');
    if (seasonId > -1) params.add('season_id=$seasonId');

    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    final EpisodeDetailResponse episodeListResp = EpisodeDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.episodeDetails, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    return episodeListResp.data.first;
  }

  //TvShow Details
  static Future<TvShowModel> getTvShowDetails({
    required int showId,
    int userId = -1,
  }) async {
    List<String> params = [];
    params.add('tvshow_id=$showId');
    params.add('device_id=${yourDevice.value.deviceId}');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    return TvShowModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.tvShowDetails, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
  }

// Add/Edit Rating
  static Future<BaseResponseModel> addRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveRating,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  static Future<BaseResponseModel> deleteRating({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.deleteRating,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Download API
  static Future<BaseResponseModel> saveDownload({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveDownload,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  static Future<BaseResponseModel> deleteFromDownload({required List<int> idList}) async {
    List<String> params = [];
    params.add('id=${idList.join(',')}');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.deleteDownloads, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Continue Watch List API
  static Future<BaseResponseModel> saveContinueWatch({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveContinueWatch,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Like Movie
  static Future<BaseResponseModel> likeMovie({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveLikes,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Watch List Movie
  static Future<BaseResponseModel> saveWatchList({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveWatchlist,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Store View Movie
  static Future<BaseResponseModel> storeViewDetails({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveEntertainmentViews,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  // Save Reminder
  static Future<BaseResponseModel> saveReminder({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveReminder,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  //Get Genres List
  static Future<RxList<GenreModel>> getGenresList({
    int page = 1,
    int? perPage,
    required List<GenreModel> getGenresList,
    Function(bool)? lastPageCallBack,
  }) async {
    perPage ??= determinePerPage();
    final genresDetails = GenresResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.genresDetails}?per_page=$perPage&page=$page",
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getGenresList.clear();
    getGenresList.addAll(genresDetails.data);
    lastPageCallBack?.call(genresDetails.data.length != perPage);
    return getGenresList.obs;
  }

  //Get Actor List
  static Future<RxList<PersonModel>> getActorsList({
    String castType = "",
    int page = 1,
    int? perPage,
    required List<PersonModel> getActorList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (castType.isNotEmpty) params.add('type=$castType');
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    final actorDetails = PersonListResp.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.actorDetails, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getActorList.clear();
    getActorList.addAll(actorDetails.data);
    lastPageCallBack?.call(actorDetails.data.length != perPage);
    return getActorList.obs;
  }

  // Movie List API
  static Future<RxList<VideoPlayerModel>> getMoviesList({
    int page = 1,
    int? perPage,
    int actorId = -1,
    int genresId = -1,
    String language = "",
    required List<VideoPlayerModel> getMovieList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (actorId > -1) params.add('actor_id=$actorId');
    if (genresId > -1) params.add('genre_id=$genresId');
    if (language.isNotEmpty) params.add('language=$language');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');

    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');

    final movieList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.movieLists, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );
    if (page == 1) getMovieList.clear();
    getMovieList.addAll(movieList.data);
    lastPageCallBack?.call(movieList.data.length != perPage);
    return getMovieList.obs;
  }

// Movie List API
  static Future<RxList<ChannelModel>> getChannelList({
    int page = 1,
    int perPage = 10,
    int category = -1,
    required List<ChannelModel> getChannelList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (category > -1) params.add('category_id=$category');
    final channelList = ChannelListModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.channelList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getChannelList.clear();
    getChannelList.addAll(channelList.data.channel);
    lastPageCallBack?.call(channelList.data.channel.length != perPage);
    return getChannelList.obs;
  }

  // TvShow List API
  static Future<RxList<VideoPlayerModel>> getTvShowsList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> getTvShowList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');
    final tvshowList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.tvShowList, params: params),
          method: HttpMethodType.GET,
          manageApiVersion: true,
        ),
      ),
    );

    if (page == 1) getTvShowList.clear();
    getTvShowList.addAll(tvshowList.data);
    lastPageCallBack?.call(tvshowList.data.length != perPage);

    return getTvShowList.obs;
  }

  // Plan List API
  static Future<RxList<SubscriptionPlanModel>> getPlanList({
    required List<SubscriptionPlanModel> getPlanList,
  }) async {
    final planList = SubscriptionResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.planLists,
          method: HttpMethodType.GET,
        ),
      ),
    );
    getPlanList.addAll(planList.data);
    return getPlanList.obs;
  }

  //Get Coming Soon List
  static Future<RxList<ComingSoonModel>> getComingSoonList({
    int page = 1,
    int perPage = 10,
    required List<ComingSoonModel> getComingSoonList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    params.add('per_page=$perPage&page=$page');
    ComingSoonResponse comingSoonDetails = ComingSoonResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.comingSoon, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getComingSoonList.clear();
    getComingSoonList.addAll(comingSoonDetails.data);
    lastPageCallBack?.call(comingSoonDetails.data.length != perPage);
    cachedComingSoonList(getComingSoonList);
    return getComingSoonList.obs;
  }

  //Get Continue Watching List

  static Future<RxList<VideoPlayerModel>> getContinueWatchingList({
    int page = 1,
    int? perPage,
    required List<VideoPlayerModel> continueWatchList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (isLoggedIn.value) params.add('user_id=${loginUserData.value.id}');
    params.add('per_page=$perPage&page=$page');

    ListResponse listResponse = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.continueWatchList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) continueWatchList.clear();
    continueWatchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return continueWatchList.obs;
  }

//region Remove from Continue Watching
  static Future<BaseResponseModel> removeContinueWatching({required int continueWatchingId}) async {
    List<String> params = [];
    params.add('id=$continueWatchingId');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.deleteContinueWatch, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

//Get Watch List
  static Future<RxList<VideoPlayerModel>> getWatchList({
    int page = 1,
    int? perPage,
    required int userId,
    required List<VideoPlayerModel> getWatchList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    if (profileId.value != 0) params.add('profile_id=${profileId.value}');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    params.add('per_page=$perPage&page=$page');

    ListResponse listResponse = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.watchList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getWatchList.clear();
    getWatchList.addAll(listResponse.data);
    lastPageCallBack?.call(listResponse.data.length != perPage);
    return getWatchList.obs;
  }

  static Future<BaseResponseModel> deleteFromWatchlist({required List<int> idList}) async {
    List<String> params = [];
    params.add('id=${idList.join(',')}');
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.deleteWatchList, params: params),
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

//Get Video List
  static Future<RxList<VideoPlayerModel>> getVideoList({
    int page = 1,
    int? perPage,
    required int userId,
    required List<VideoPlayerModel> getVideoList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    params.add('per_page=$perPage&page=$page');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');
    final videoList = ListResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.videoList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) getVideoList.clear();
    getVideoList.addAll(videoList.data);
    lastPageCallBack?.call(videoList.data.length != perPage);
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    return getVideoList.obs;
  }

//Get Episodes List
  static Future<RxList<EpisodeModel>> getEpisodesList({
    int page = 1,
    int perPage = 10,
    required int showId,
    int seasonId = -1,
    int userId = -1,
    required List<EpisodeModel> episodeList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (seasonId > -1) params.add('season_id=$seasonId');
    if (showId > -1) params.add('show_id=$showId');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    EpisodeDetailResponse it = EpisodeDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.episodeList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) episodeList.clear();
    log(it.data.length < perPage);
    lastPageCallBack?.call(it.data.length < perPage);
    episodeList.addAll(it.data);

    return episodeList.obs;
  }

  //Get Episodes List Season Id Wise Mapping
  static Future<RxMap<int, RxList<EpisodeModel>>> getSeasonWiseEpisodesList({
    int page = 1,
    int perPage = 20,
    required int showId,
    int seasonId = -1,
    int userId = -1,
    required RxMap<int, RxList<EpisodeModel>> seasonIdWiseEpisodeList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (seasonId > -1) params.add('season_id=$seasonId');
    if (showId > -1) params.add('show_id=$showId');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    EpisodeDetailResponse it = EpisodeDetailResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.episodeList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    seasonIdWiseEpisodeList.putIfAbsent(seasonId, () => RxList());
    if (page == 1) seasonIdWiseEpisodeList[seasonId]?.clear();
    log(it.data.length < perPage);
    lastPageCallBack?.call(it.data.length < perPage);
    seasonIdWiseEpisodeList[seasonId]?.addAll(it.data);

    return seasonIdWiseEpisodeList;
  }

//Edit Profile API
  static Future<void> updateProfileReq({
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.editProfile);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file_url',
          files.validate().first.path.validate(),
        ),
      );
    }

    log("Multipart ${jsonEncode(multiPartRequest.fields)}");
    log("Multipart Files ${multiPartRequest.files.map((e) => e.filename)}");
    log("Multipart Extension ${multiPartRequest.files.map((e) => e.filename!.split(".").last)}");
    multiPartRequest.headers.addAll(buildHeaderTokens());

    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      log("Response: ${jsonDecode(temp)}");
      final baseResponseModel = BaseResponseModel.fromJson(jsonDecode(temp));
      toast(baseResponseModel.message, print: true);
      onSuccess?.call();
    }, onError: (error, data) {
      log(error);
      throw error;
    });
  }

//Page List Setting Screen
  static Future<AboutPageResponse> getPageList() async {
    return AboutPageResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(APIEndPoints.pageList, method: HttpMethodType.GET),
      ),
    );
  }

  static Future<BaseResponseModel> saveViewCompleted({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(APIEndPoints.saveEntertainmentCompletedView,
            request: request, method: HttpMethodType.POST),
      ),
    );
  }

//region Watching Profile
  static Future<RxList<WatchingProfileModel>> getWatchingProfileList({
    int page = 1,
    int perPage = 10,
    required List<WatchingProfileModel> profileList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    try {
      WatchingProfileResponse profileResponseModel = WatchingProfileResponse.fromJson(
        await handleResponse(
          await buildHttpResponse(
            getEndPoint(endPoint: APIEndPoints.getWatchingProfileList, params: params),
            method: HttpMethodType.GET,
          ),
        ),
      );
      if (page == 1) profileList.clear();
      profileList.addAll(profileResponseModel.data);
      lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    } catch (e) {
      rethrow;
    }
    return profileList.obs;
  }

// Watching Edit Profile
  static Future<WatchingProfileResponse> updateWatchProfile({
    required Map<String, dynamic> request,
    List<File>? files,
    VoidCallback? onSuccess,
  }) async {
    var multiPartRequest = await getMultiPartRequest(APIEndPoints.editWatchingProfile);
    multiPartRequest.fields.addAll(await getMultipartFields(val: request));

    if (files.validate().isNotEmpty) {
      multiPartRequest.files.add(
        await http.MultipartFile.fromPath(
          'file_url',
          files.validate().first.path.validate(),
        ),
      );
    }

    multiPartRequest.headers.addAll(buildHeaderTokens());
    WatchingProfileResponse profileWatchingResponseModel =
        WatchingProfileResponse(newUserProfile: WatchingProfileModel());
    await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
      profileWatchingResponseModel = WatchingProfileResponse.fromJson(jsonDecode(temp));
    }, onError: (error, response) {
      profileWatchingResponseModel = WatchingProfileResponse(newUserProfile: WatchingProfileModel());
      if (response.statusCode == 406) {
        throw {
          "error": error,
          "status_code": response.statusCode,
        };
      } else {
        throw error;
      }
    });
    return profileWatchingResponseModel;
  }

// Watching Delete Profile
  static Future<BaseResponseModel> deleteWatchingProfile({required Map request}) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.deleteWatchingProfile,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

  /// Search Apis
// Save search
  static Future<WatchingProfileResponse> saveSearch({required Map request}) async {
    return WatchingProfileResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          APIEndPoints.saveSearch,
          request: request,
          method: HttpMethodType.POST,
        ),
      ),
    );
  }

// Clear All
  static Future<WatchingProfileResponse> clearAll(int? isProfileID) async {
    return WatchingProfileResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.deleteSearch}?profile_id=$isProfileID&type=clear_all",
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

// Particular Search Delete
  static Future<BaseResponseModel> particularSearchDelete(int id, int profileId) async {
    return BaseResponseModel.fromJson(
      await handleResponse(
        await buildHttpResponse(
          "${APIEndPoints.deleteSearch}?profile_id=$profileId&id=$id",
          method: HttpMethodType.GET,
        ),
      ),
    );
  }

  static Future<List<FAQModel>> getFAQList({
    int page = 1,
    int perPage = 10,
    required List<FAQModel> faqList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    FAQResponse res = FAQResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.faqList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) faqList.clear();
    lastPageCallBack?.call(res.data.length != perPage);
    faqList.addAll(res.data);

    return faqList;
  }

// Plan List API
  static Future<RxList<SubscriptionPlanModel>> getSubscriptionHistory({
    int page = 1,
    int perPage = 10,
    required List<SubscriptionPlanModel> subscriptionHistoryList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    params.add('per_page=$perPage&page=$page');
    SubscriptionResponse profileResponseModel = SubscriptionResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.subscriptionHistory, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) subscriptionHistoryList.clear();
    subscriptionHistoryList.addAll(profileResponseModel.data);
    lastPageCallBack?.call(profileResponseModel.data.length != perPage);
    return subscriptionHistoryList.obs;
  }

  static Future<RxList<SliderModel>> getSliderDetail({
    required List<SliderModel> getBannerList,
    required String type,
  }) async {
    List<String> params = [];
    params.add('type=$type');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');
    final response = await handleResponse(
      await buildHttpResponse(
        getEndPoint(
          endPoint: getEndPoint(
            endPoint: APIEndPoints.bannerList,
            params: params,
          ),
        ),
      ),
    );
    if (response is Map && response['data'] is Map && response['data']['slider'] is List) {
      final bannerList = (response['data']['slider'] as List).map((json) => SliderModel.fromJson(json)).toList();
      return RxList<SliderModel>(bannerList);
    } else {
      return RxList<SliderModel>();
    }
  }

  // TV Session Check API QR Linking
  static Future<TVSessionResponse> initiateSession() async {
    TVSessionResponse tvSessionDetailsResp = TVSessionResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.initiateSession),
          method: HttpMethodType.GET,
        ),
      ),
    );

    return tvSessionDetailsResp;
  }

  static Future<UserResponse> tvSessionCheck({required String sessionId}) async {
    List<String> params = [];

    Map<String, dynamic> request = {
      APIKeys.sessionIdKey: sessionId,
    };

    if (yourDevice.value.deviceId.isNotEmpty) request[APIKeys.deviceIdKey] = yourDevice.value.deviceId;
    if (yourDevice.value.deviceName.isNotEmpty) request[APIKeys.deviceNameKey] = yourDevice.value.deviceName;
    if (yourDevice.value.platform.isNotEmpty) request[APIKeys.platformKey] = yourDevice.value.platform;

    UserResponse tvSessionDetailsResp = UserResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.tvSessionCheck,
            params: params,
          ),
          method: HttpMethodType.POST,
          request: request,
        ),
      ),
    );

    return tvSessionDetailsResp;
  }

  static Future<RxList<VideoPlayerModel>> getRentedContent({
    int page = 1,
    int? perPage,
    int actorId = -1,
    int genresId = -1,
    String language = "",
    required List<VideoPlayerModel> rentedContentList,
    Function(bool)? lastPageCallBack,
  }) async {
    List<String> params = [];
    perPage ??= determinePerPage();
    params.add('per_page=$perPage&page=$page');
    if (loginUserData.value.id > -1) params.add('user_id=${loginUserData.value.id}');
    if (selectedAccountProfile.value.isChildProfile.validate() == 1) params.add('is_restricted=0');
    RentedContent movieList = RentedContent.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(endPoint: APIEndPoints.rentedContentList, params: params),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (page == 1) rentedContentList.clear();
    rentedContentList
        .addAll(movieList.data.movies + movieList.data.tvshows + movieList.data.videos + movieList.data.episodes);
    lastPageCallBack?.call((movieList.data.movies.length +
            movieList.data.tvshows.length +
            movieList.data.videos.length +
            movieList.data.episodes.length) !=
        perPage);
    return rentedContentList.obs;
  }

  static Future<BaseResponseModel> startRentedContentDate({required Map request}) async {
    return BaseResponseModel.fromJson(await handleResponse(
        await buildHttpResponse(APIEndPoints.startDate, request: request, method: HttpMethodType.POST)));
  }

  static Future<VastAdResponse?> getVastAds() async {
    VastAdResponse res = VastAdResponse.fromJson(
      await handleResponse(
        await buildHttpResponse(
          getEndPoint(
            endPoint: APIEndPoints.getActiveVastAds,
          ),
          method: HttpMethodType.GET,
        ),
      ),
    );
    if (res.success.validate()) {
      return res;
    } else {
      return null;
    }
  }

}
