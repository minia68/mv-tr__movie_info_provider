import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'proxy_list_item.dart';

class ProxyFinder {
  final BaseOptions proxyDioOptions;
  final List<Interceptor> interceptors;
  Dio? proxyDio;
  int lastIndex = 0;
  List<ProxyListItem>? proxyListItems;

  ProxyFinder._(this.proxyDioOptions, this.interceptors);

  factory ProxyFinder([
    BaseOptions? proxyDioOptions,
    List<Interceptor>? interceptors,
  ]) {
    proxyDioOptions ??= BaseOptions();
    proxyDioOptions.connectTimeout = const Duration(milliseconds: 5000);
    proxyDioOptions.receiveTimeout = const Duration(milliseconds: 5000);
    proxyDioOptions.sendTimeout = const Duration(milliseconds: 5000);
    interceptors ??= [];
    return ProxyFinder._(proxyDioOptions, interceptors);
  }

  Future loadProxyList() async {
    final response = await Dio().get<String>(
        'https://raw.githubusercontent.com/fate0/proxylist/master/proxy.list');
    proxyListItems = response.data
        ?.split('\n')
        .map((e) => ProxyListItem.fromJson(json.decode(e)))
        .skip(lastIndex)
        .take(30)
        .toList();
  }

  Future findProxy() async {
    if (proxyListItems == null || proxyListItems!.isEmpty) {
      await loadProxyList();
    }
    while (lastIndex < proxyListItems!.length) {
      setProxy(proxyListItems![lastIndex]);
      try {
        final response = await proxyDio!.get<String>('https://www.google.com');
        if (!(response.data?.contains('<title>Google</title>') ?? false)) {
          throw ProxyFinderException('bad response body');
        }
        break;
      } catch (e) {
        lastIndex++;
      }
    }
    if (lastIndex == proxyListItems!.length) {
      throw ProxyFinderException('cant find working proxy');
    }
  }

  void setProxy(ProxyListItem proxyListItem) {
    proxyDio?.close(force: true);
    proxyDio = Dio(proxyDioOptions)..interceptors.addAll(interceptors);
    proxyDio!.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy =
            (uri) => 'PROXY ${proxyListItem.host}:${proxyListItem.port}';
        return client;
      },
    );
  }
}

class ProxyFinderException implements Exception {
  final String message;

  ProxyFinderException(this.message);
}
