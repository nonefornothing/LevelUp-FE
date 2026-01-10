import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/social_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../domain/entities/friend.dart';
import 'social_event.dart';
import 'social_state.dart';

/// BLoC for managing social features
class SocialBloc extends Bloc<SocialEvent, SocialState> {
  final SocialService _socialService;

  SocialBloc({SocialService? socialService})
      : _socialService = socialService ?? sl<SocialService>(),
        super(const SocialInitial()) {
    on<LoadFriends>(_onLoadFriends);
    on<RefreshFriends>(_onRefreshFriends);
    on<AddFriend>(_onAddFriend);
    on<RemoveFriend>(_onRemoveFriend);
    on<LoadFriendRequests>(_onLoadFriendRequests);
    on<SendFriendRequest>(_onSendFriendRequest);
    on<AcceptFriendRequest>(_onAcceptFriendRequest);
    on<RejectFriendRequest>(_onRejectFriendRequest);
    on<LoadSharedQuests>(_onLoadSharedQuests);
    on<ShareQuest>(_onShareQuest);
    on<AcceptSharedQuest>(_onAcceptSharedQuest);
    on<CompareProgressWithFriend>(_onCompareProgressWithFriend);
  }

  Future<void> _onLoadFriends(
    LoadFriends event,
    Emitter<SocialState> emit,
  ) async {
    emit(const SocialLoading());
    await _loadAllData(emit);
  }

  Future<void> _onRefreshFriends(
    RefreshFriends event,
    Emitter<SocialState> emit,
  ) async {
    await _loadAllData(emit);
  }

  Future<void> _loadAllData(Emitter<SocialState> emit) async {
    final friendsResult = await _socialService.getFriends();
    final requestsResult = await _socialService.getFriendRequests();
    final sharedQuestsResult = await _socialService.getSharedQuests();

    if (friendsResult is ResultError ||
        requestsResult is ResultError ||
        sharedQuestsResult is ResultError) {
      emit(SocialError('Failed to load social data'));
      return;
    }

    final friends = (friendsResult as Success).data;
    final requests = (requestsResult as Success).data;
    final sharedQuests = (sharedQuestsResult as Success).data;

    emit(FriendsLoaded(
      friends: friends,
      friendRequests: requests,
      sharedQuests: sharedQuests,
    ));
  }

  Future<void> _onAddFriend(
    AddFriend event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.addFriendByUsername(event.username);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<Friend>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onRemoveFriend(
    RemoveFriend event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.removeFriend(event.friendId);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<void>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onLoadFriendRequests(
    LoadFriendRequests event,
    Emitter<SocialState> emit,
  ) async {
    await _loadAllData(emit);
  }

  Future<void> _onSendFriendRequest(
    SendFriendRequest event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.sendFriendRequest(
      toUserId: event.toUserId,
      toUsername: event.toUsername,
    );
    if (result is ResultError) {
      emit(SocialError((result as ResultError<FriendRequest>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onAcceptFriendRequest(
    AcceptFriendRequest event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.acceptFriendRequest(event.requestId);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<Friend>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onRejectFriendRequest(
    RejectFriendRequest event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.rejectFriendRequest(event.requestId);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<void>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onLoadSharedQuests(
    LoadSharedQuests event,
    Emitter<SocialState> emit,
  ) async {
    await _loadAllData(emit);
  }

  Future<void> _onShareQuest(
    ShareQuest event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.shareQuestWithFriend(
      questId: event.questId,
      questTitle: event.questTitle,
      friendId: event.friendId,
    );
    if (result is ResultError) {
      emit(SocialError((result as ResultError<SharedQuest>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onAcceptSharedQuest(
    AcceptSharedQuest event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.acceptSharedQuest(event.sharedQuestId);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<void>).message));
      return;
    }
    await _loadAllData(emit);
  }

  Future<void> _onCompareProgressWithFriend(
    CompareProgressWithFriend event,
    Emitter<SocialState> emit,
  ) async {
    final result = await _socialService.compareProgressWithFriend(event.friendId);
    if (result is ResultError) {
      emit(SocialError((result as ResultError<Map<String, dynamic>>).message));
      return;
    }
    emit(ProgressComparisonLoaded((result as Success<Map<String, dynamic>>).data));
  }
}

