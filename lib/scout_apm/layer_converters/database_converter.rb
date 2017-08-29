module ScoutApm
  module LayerConverters
    class DatabaseConverter < ConverterBase
      def register_hooks(walker)
        super
        return {} unless scope_layer

        @db_query_metric_set = DbQueryMetricSet.new

        walker.on do |layer|
          next if skip_layer?(layer)

          stat = DbQueryMetricStats.new(
            layer.name.model,
            layer.name.normalized_operation,
            1,
            layer.total_call_time,
            layer.annotations[:record_count])
          @db_query_metric_set.combine!(stat)
        end
      end

      def skip_layer?(layer)
        super || layer.annotations.nil? || layer.type != 'ActiveRecord'
      end

      def record!
        @store.track_db_query_metrics!(@db_query_metric_set)
      end
    end
  end
end