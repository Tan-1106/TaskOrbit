import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_orbit/firebase_options.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';
import 'package:task_orbit/core/common/locale/locale_notifier.dart';

import 'package:task_orbit/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:task_orbit/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';
import 'package:task_orbit/features/authentication/domain/usecases/change_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/get_current_user.dart';
import 'package:task_orbit/features/authentication/domain/usecases/send_email_verification.dart';
import 'package:task_orbit/features/authentication/domain/usecases/check_email_verified.dart';
import 'package:task_orbit/features/authentication/domain/usecases/delete_current_user.dart';
import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';

import 'package:task_orbit/core/database/app_database.dart';
import 'package:task_orbit/core/network/connectivity_service.dart';
import 'package:task_orbit/core/services/notification_service.dart';
import 'package:task_orbit/features/agenda/data/datasources/task_local_data_source.dart';
import 'package:task_orbit/features/agenda/data/datasources/task_remote_data_source.dart';
import 'package:task_orbit/features/agenda/data/repositories/task_repository_impl.dart';
import 'package:task_orbit/features/agenda/domain/repository/task_repository.dart';
import 'package:task_orbit/features/agenda/domain/usecases/get_tasks_by_date.dart';
import 'package:task_orbit/features/agenda/domain/usecases/create_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/update_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/delete_task.dart';
import 'package:task_orbit/features/agenda/domain/usecases/toggle_task_complete.dart';
import 'package:task_orbit/features/agenda/domain/usecases/search_tasks.dart';
import 'package:task_orbit/features/agenda/domain/usecases/sync_tasks.dart';
import 'package:task_orbit/features/agenda/domain/usecases/get_tasks_for_period.dart';
import 'package:task_orbit/features/agenda/data/datasources/category_local_data_source.dart';
import 'package:task_orbit/features/agenda/data/datasources/category_remote_data_source.dart';
import 'package:task_orbit/features/agenda/data/repositories/category_repository_impl.dart';
import 'package:task_orbit/features/agenda/domain/repository/category_repository.dart';
import 'package:task_orbit/features/agenda/domain/usecases/get_categories.dart';
import 'package:task_orbit/features/agenda/domain/usecases/create_category.dart';
import 'package:task_orbit/features/agenda/domain/usecases/delete_category.dart';
import 'package:task_orbit/features/agenda/domain/usecases/sync_categories.dart';
import 'package:task_orbit/features/agenda/presentation/bloc/agenda_bloc.dart';

import 'package:task_orbit/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:task_orbit/features/pomodoro/data/datasources/pomodoro_preset_local_data_source.dart';
import 'package:task_orbit/features/pomodoro/data/datasources/pomodoro_preset_remote_data_source.dart';
import 'package:task_orbit/features/pomodoro/data/repositories/pomodoro_repository_impl.dart';
import 'package:task_orbit/features/pomodoro/domain/repository/i_pomodoro_preset_repository.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/get_presets.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/save_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/delete_preset.dart';
import 'package:task_orbit/features/pomodoro/domain/usecases/sync_presets.dart';
import 'package:task_orbit/features/pomodoro/presentation/bloc/pomodoro_bloc.dart';

part 'init_dependencies.main.dart';
