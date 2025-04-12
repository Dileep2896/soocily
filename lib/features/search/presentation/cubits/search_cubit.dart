import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soocily/features/search/domain/search_repo.dart';
import 'package:soocily/features/search/presentation/cubits/search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchRepo searchRepo;

  SearchCubit({required this.searchRepo}) : super(SearchInitialState());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      emit(SearchInitialState());
      return;
    }

    try {
      emit(SearchLoadingState());
      final users = await searchRepo.searchUsers(query);
      if (users.isEmpty) {
        emit(SearchErrorState('No users found'));
      } else {
        emit(SearchLoadedState(users));
      }
    } catch (e) {
      emit(SearchErrorState(e.toString()));
    }
  }
}
