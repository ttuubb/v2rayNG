// Mocks generated by Mockito 5.4.5 from annotations
// in v2rayng/test/widgets/server_list_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:v2rayng/models/repositories/server_repository.dart' as _i2;
import 'package:v2rayng/models/server_config.dart' as _i4;

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

/// A class which mocks [ServerRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockServerRepository extends _i1.Mock implements _i2.ServerRepository {
  MockServerRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<List<_i4.ServerConfig>> getAllServers() =>
      (super.noSuchMethod(
            Invocation.method(#getAllServers, []),
            returnValue: _i3.Future<List<_i4.ServerConfig>>.value(
              <_i4.ServerConfig>[],
            ),
          )
          as _i3.Future<List<_i4.ServerConfig>>);

  @override
  _i3.Future<void> addServer(_i4.ServerConfig? server) =>
      (super.noSuchMethod(
            Invocation.method(#addServer, [server]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> updateServer(_i4.ServerConfig? server) =>
      (super.noSuchMethod(
            Invocation.method(#updateServer, [server]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> saveServer(_i4.ServerConfig? server) =>
      (super.noSuchMethod(
            Invocation.method(#saveServer, [server]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<List<_i4.ServerConfig>> getServersBySubscriptionId(
    String? subscriptionId,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#getServersBySubscriptionId, [subscriptionId]),
            returnValue: _i3.Future<List<_i4.ServerConfig>>.value(
              <_i4.ServerConfig>[],
            ),
          )
          as _i3.Future<List<_i4.ServerConfig>>);

  @override
  _i3.Future<void> deleteServer(String? serverId) =>
      (super.noSuchMethod(
            Invocation.method(#deleteServer, [serverId]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> saveAllServers(List<_i4.ServerConfig>? servers) =>
      (super.noSuchMethod(
            Invocation.method(#saveAllServers, [servers]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> clearAllServers() =>
      (super.noSuchMethod(
            Invocation.method(#clearAllServers, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}
