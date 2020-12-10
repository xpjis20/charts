// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:meta/meta.dart' show required;

import '../../../common/graphics_factory.dart' show GraphicsFactory;
import '../../common/chart_context.dart' show ChartContext;
import 'axis.dart' show AxisOrientation;
import 'draw_strategy/tick_draw_strategy.dart' show TickDrawStrategy;
import 'numeric_scale.dart' show NumericScale;
import 'ordinal_scale.dart' show OrdinalScale;
import 'scale.dart' show MutableScale;
import 'tick.dart' show Tick;
import 'tick_formatter.dart' show TickFormatter;
import 'tick_provider.dart' show BaseTickProvider, TickHint;
import 'time/date_time_scale.dart' show DateTimeScale;


/// Tick provider that provides ticks at the two end points of the axis range.
class EndPointsTickProvider<D> extends BaseTickProvider<D> {
  final int domainproviderTickCount;
  const EndPointsTickProvider({this.domainproviderTickCount});
  @override
  List<Tick<D>> getTicks({
    @required ChartContext context,
    @required GraphicsFactory graphicsFactory,
    @required MutableScale<D> scale,
    @required TickFormatter<D> formatter,
    @required Map<D, String> formatterValueCache,
    @required TickDrawStrategy tickDrawStrategy,
    @required AxisOrientation orientation,
    bool viewportExtensionEnabled = false,
    TickHint<D> tickHint,
  }) {
    final ticks = <Tick<D>>[];

    // Check to see if the axis has been configured with some domain values.
    //
    // An un-configured axis has no domain step size, and its scale defaults to
    // infinity.
    if (scale.domainStepSize.abs() != double.infinity) {
      List<D> position = _getPositionValue(tickHint, scale);
    
      final labels = formatter.format(position, formatterValueCache,
          stepSize: scale.domainStepSize);

      for (int i = 0; i < 11; i++) {
        ticks.add(Tick(
            value: position[i],
            textElement: graphicsFactory.createTextElement(labels[i]),
            locationPx: scale[position[i]]));
      }
      // ticks.add(Tick(
      //     value: middle,
      //     textElement: graphicsFactory.createTextElement(labels[1]),
      //     locationPx: scale[middle]));
      //locationPx: 100));

      // ticks.add(Tick(
      //     value: end,
      //     textElement: graphicsFactory.createTextElement(labels[2]),
      //     locationPx: scale[end]));

      // Allow draw strategy to decorate the ticks.
      tickDrawStrategy.decorateTicks(ticks);
    }

    return ticks;
  }

// 10칸으로 나누어표시함, 임시
  List<D> _getPositionValue(TickHint<D> tickHint, MutableScale<D> scale) {
    List<D> positionValue = new List<D>();
    //int timeseconds = 120;
    for (int i = 11; i > 0; i--) {
      Object value;
      value = (scale as DateTimeScale).viewportDomain.end.subtract(
          Duration(seconds: (this.domainproviderTickCount ~/ 11) * i));
      //Duration(seconds: ( ~/ 11) * i));
      positionValue.add(value);
    }
    return positionValue;
  }

  /// Get the start value from the scale.
  D _getStartValue(TickHint<D> tickHint, MutableScale<D> scale) {
    Object start;

    if (tickHint != null) {
      start = tickHint.start;
    } else {
      if (scale is NumericScale) {
        start = (scale as NumericScale).viewportDomain.min;
      } else if (scale is DateTimeScale) {
        start = (scale as DateTimeScale).viewportDomain.start;
      } else if (scale is OrdinalScale) {
        start = (scale as OrdinalScale).domain.first;
      }
    }

    return start;
  }

  /// Get the end value from the scale.
  D _getEndValue(TickHint<D> tickHint, MutableScale<D> scale) {
    Object end;

    if (tickHint != null) {
      end = tickHint.end;
    } else {
      if (scale is NumericScale) {
        end = (scale as NumericScale).viewportDomain.max;
      } else if (scale is DateTimeScale) {
        end = (scale as DateTimeScale).viewportDomain.end;
      } else if (scale is OrdinalScale) {
        end = (scale as OrdinalScale).domain.last;
      }
    }

    return end;
  }
}
