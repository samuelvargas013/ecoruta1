import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/location_service.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/repositories/report_repository.dart';

import '../../domain/usecases/auth/google_sign_in_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/auth/sign_in_usecase.dart';
import '../../domain/usecases/auth/sign_out_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/profile/get_badges_usecase.dart';
import '../../domain/usecases/profile/watch_profile_usecase.dart';
import '../../domain/usecases/report/create_report_usecase.dart';
import '../../domain/usecases/report/mark_collected_usecase.dart';
import '../../domain/usecases/report/watch_active_reports_usecase.dart';
import '../../domain/usecases/report/watch_my_reports_usecase.dart';

/// Service locator. Registra todas las dependencias de la app.
final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // ---------- Externos (Firebase / plugins) ----------
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // ---------- DataSources ----------
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      auth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl()),
  );

  // ---------- Repositorios ----------
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ReportRepository>(() => ReportRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl()));

  // ---------- Casos de uso (F-01) ----------
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // ---------- Casos de uso (F-02, F-03, F-04) ----------
  sl.registerLazySingleton(() => CreateReportUseCase(sl()));
  sl.registerLazySingleton(() => WatchActiveReportsUseCase(sl()));
  sl.registerLazySingleton(() => WatchMyReportsUseCase(sl()));
  sl.registerLazySingleton(() => MarkCollectedUseCase(sl()));

  // ---------- Casos de uso (F-05) ----------
  sl.registerLazySingleton(() => WatchProfileUseCase(sl()));
  sl.registerLazySingleton(() => GetBadgesUseCase(sl()));
}
