import 'failure.dart';

abstract class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T get value {
    if (this is Success<T>) {
      return (this as Success<T>).data;
    }
    throw StateError('Called get value on Error result');
  }

  Failure get error {
    if (this is Error<T>) {
      return (this as Error<T>).failure;
    }
    throw StateError('Called get error on Success result');
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
