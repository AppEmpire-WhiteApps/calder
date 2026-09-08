import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks the reader's position in Calder's introductory security briefing.
class BriefingProgressCubit extends Cubit<int> {
  BriefingProgressCubit({required this.slideCount})
    : assert(slideCount > 0),
      super(0);

  final int slideCount;
  bool _closed = false;

  bool get isFinalSlide => state == slideCount - 1;

  void moveTo(int index) {
    if (index < 0 || index >= slideCount || index == state) return;
    if (!_closed) emit(index);
  }

  @override
  Future<void> close() {
    _closed = true;
    return super.close();
  }
}
