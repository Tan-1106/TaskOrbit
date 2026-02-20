// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Application
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_orbit/firebase_options.dart';
import 'package:task_orbit/core/auth/app_auth_notifier.dart';

// Authentication Feature
import 'package:task_orbit/features/authentication/data/datasources/auth_remote_data_source.dart';
import 'package:task_orbit/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:task_orbit/features/authentication/domain/repository/auth_repository.dart';
import 'package:task_orbit/features/authentication/domain/usecases/forgot_password.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_login.dart';
import 'package:task_orbit/features/authentication/domain/usecases/user_sign_up.dart';
import 'package:task_orbit/features/authentication/presentation/bloc/auth_bloc.dart';

part 'init_dependencies.main.dart';
