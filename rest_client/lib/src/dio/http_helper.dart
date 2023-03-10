import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_dio_http_cache/dio_http_cache.dart';
import 'package:rest_client/flutter_rest_client.dart';


abstract class IHttpHelper {
  Future<dynamic> request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic> headers});
}

class HttpHelper implements IHttpHelper {
  final Dio _dio;
  CancelToken cancelToken = CancelToken();
  IHttpConfig config;

  HttpHelper({required this.config})
      : _dio = DioBuilder(config: config).build();

  @override
  Future request(IRequestEndPoint endPoint, IRequestModel requestModel,
      {Map<String, dynamic>? headers, bool cacheRequest = false}) async {
    try {
      switch (endPoint.method) {
        case RequestMethod.DELETE:
          return (await _dio.delete(endPoint.url,
                  options: Options(headers: headers),
                  queryParameters: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.GET:
          if (cacheRequest) {
            final _dioCacheManager = DioCacheManager(CacheConfig(
              baseUrl: endPoint.url,
            ));
            _dio.interceptors.add(_dioCacheManager.interceptor);
          }
          return (await _dio.get(endPoint.url,
                  options: cacheRequest
                      ? buildConfigurableCacheOptions(
                          options: Options(headers: headers),
                          forceRefresh: true)
                      : Options(headers: headers),
                  queryParameters: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;

        case RequestMethod.POST:
          return (await _dio.post(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.PATCH:
          return (await _dio.patch(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
        case RequestMethod.PUT:
          return (await _dio.put(endPoint.url,
                  options: Options(headers: headers),
                  data: requestModel.toJson(),
                  cancelToken: cancelToken))
              .data;
      }
    } on DioError catch (e) {
      switch (e.response?.statusCode) {
        case 400:
        case 401:
        case 403:
      }
      return e.response?.data;
    } on SocketException catch (e) {
      throw SocketException(e.toString());
    } on FormatException catch (_) {
      throw FormatException();
    } catch (e) {
      throw e;
    }
  }
}
