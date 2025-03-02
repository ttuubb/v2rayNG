// Mocks generated by Mockito 5.4.5 from annotations
// in v2rayng/test/unit/viewmodels/log_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:io' as _i2;

import 'package:mockito/mockito.dart' as _i1;
import 'package:v2rayng/core/event_bus.dart' as _i5;
import 'package:v2rayng/core/services/log_service.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFile_0 extends _i1.SmartFake implements _i2.File {
  _FakeFile_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [LogService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLogService extends _i1.Mock implements _i3.LogService {
  MockLogService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Stream<_i3.LogEntry> get logStream =>
      (super.noSuchMethod(
            Invocation.getter(#logStream),
            returnValue: _i4.Stream<_i3.LogEntry>.empty(),
          )
          as _i4.Stream<_i3.LogEntry>);

  @override
  void debug(String? message, {String? tag, String? details}) =>
      super.noSuchMethod(
        Invocation.method(#debug, [message], {#tag: tag, #details: details}),
        returnValueForMissingStub: null,
      );

  @override
  void info(String? message, {String? tag, String? details}) =>
      super.noSuchMethod(
        Invocation.method(#info, [message], {#tag: tag, #details: details}),
        returnValueForMissingStub: null,
      );

  @override
  void warning(String? message, {String? tag, String? details}) =>
      super.noSuchMethod(
        Invocation.method(#warning, [message], {#tag: tag, #details: details}),
        returnValueForMissingStub: null,
      );

  @override
  void error(String? message, {String? tag, String? details}) =>
      super.noSuchMethod(
        Invocation.method(#error, [message], {#tag: tag, #details: details}),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<List<_i3.LogEntry>> getLogs() =>
      (super.noSuchMethod(
            Invocation.method(#getLogs, []),
            returnValue: _i4.Future<List<_i3.LogEntry>>.value(<_i3.LogEntry>[]),
          )
          as _i4.Future<List<_i3.LogEntry>>);

  @override
  _i4.Future<List<_i3.LogEntry>> getLogsByLevel(_i3.LogLevel? level) =>
      (super.noSuchMethod(
            Invocation.method(#getLogsByLevel, [level]),
            returnValue: _i4.Future<List<_i3.LogEntry>>.value(<_i3.LogEntry>[]),
          )
          as _i4.Future<List<_i3.LogEntry>>);

  @override
  _i4.Future<List<_i3.LogEntry>> getLogsByTag(String? tag) =>
      (super.noSuchMethod(
            Invocation.method(#getLogsByTag, [tag]),
            returnValue: _i4.Future<List<_i3.LogEntry>>.value(<_i3.LogEntry>[]),
          )
          as _i4.Future<List<_i3.LogEntry>>);

  @override
  _i4.Future<void> clearLogs() =>
      (super.noSuchMethod(
            Invocation.method(#clearLogs, []),
            returnValue: _i4.Future<void>.value(),
            returnValueForMissingStub: _i4.Future<void>.value(),
          )
          as _i4.Future<void>);

  @override
  _i4.Future<_i2.File> exportLogs() =>
      (super.noSuchMethod(
            Invocation.method(#exportLogs, []),
            returnValue: _i4.Future<_i2.File>.value(
              _FakeFile_0(this, Invocation.method(#exportLogs, [])),
            ),
          )
          as _i4.Future<_i2.File>);

  @override
  void setMaxEntries(int? maxEntries) => super.noSuchMethod(
    Invocation.method(#setMaxEntries, [maxEntries]),
    returnValueForMissingStub: null,
  );
}

/// A class which mocks [EventBus].
///
/// See the documentation for Mockito's code generation for more information.
class MockEventBus extends _i1.Mock implements _i5.EventBus {
  MockEventBus() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void emit<T>(T? event) => super.noSuchMethod(
    Invocation.method(#emit, [event]),
    returnValueForMissingStub: null,
  );

  @override
  _i4.Stream<T> on<T>() =>
      (super.noSuchMethod(
            Invocation.method(#on, []),
            returnValue: _i4.Stream<T>.empty(),
          )
          as _i4.Stream<T>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );
}
