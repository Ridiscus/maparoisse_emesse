// lib/services/request_notifier.dart

import 'package:flutter/material.dart';

/// Un simple notificateur pour signaler que la liste des demandes a changé.
final requestNotifier = ValueNotifier<int>(0);