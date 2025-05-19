import 'package:get_it/get_it.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/videos/data/video_repository.dart';
import '../../features/user/data/user_repository.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Repositories
  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<VideoRepository>(VideoRepository());
  getIt.registerSingleton<UserRepository>(UserRepository());
}
