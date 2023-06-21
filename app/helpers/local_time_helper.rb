module LocalTimeHelper
  def local_time(time, options = nil)
    time = utc_time(time)

    options, format = extract_options_and_value(options, :format)
    format = find_time_format(format)

    options[:data] ||= {}
    options[:data].merge! local: :time, format: format

    time_tag time, time.strftime(format), options
  end

  def local_date(time, options = nil)
    time = utc_time(time)

    options, format = extract_options_and_value(options, :format)
    format = find_date_format(format)

    options[:data] ||= {}
    options[:data].merge! local: :time, type: :date, format: format

    time_tag time, time.strftime(format), options
  end

  def local_relative_time(time, options = nil)
    time = utc_time(time)
    options, type = extract_options_and_value(options, :type)

    options[:data] ||= {}
    options[:data].merge! local: type

    time_tag time, time.strftime(LocalTime.default_time_format), options
  end

  def local_time_ago(time, options = nil)
    options, * = extract_options_and_value(options, :type)
    options[:type] = 'time-ago'
    local_relative_time time, options
  end

  def utc_time(time_or_date)
    if time_or_date.respond_to?(:in_time_zone)
      time_or_date.in_time_zone.utc
    else
      time_or_date.to_time.utc
    end
  end

  private

    def find_time_format(format)
      find_format(format, find_i18n_time_format(format), find_ruby_time_format(format), LocalTime.default_time_format)
    end

    def find_date_format(format)
      find_format(format, find_i18n_date_format(format), find_ruby_date_format(format), LocalTime.default_date_format)
    end

    def find_format(format, i18n_format, ruby_format, default_format)
      if format.is_a?(Symbol)
        if i18n_format
          i18n_format
        elsif ruby_format
          ruby_format.is_a?(Proc) ? default_format : ruby_format
        else
          default_format
        end
      else
        format.presence || default_format
      end
    end

    def find_i18n_time_format(format); find_i18n_format(format, :time); end
    def find_i18n_date_format(format); find_i18n_format(format, :date); end
    def find_i18n_format(format, type)
      I18n.t("#{type}.formats.#{format}", default: "").presence
    end

    def find_ruby_time_format(format); Time::DATE_FORMATS[format]; end
    def find_ruby_date_format(format); Date::DATE_FORMATS[format]; end

    def extract_options_and_value(options, value_key = nil)
      case options
      when Hash
        value = options.delete(value_key)
        [ options, value ]
      when NilClass
        [ {} ]
      else
        [ {}, options ]
      end
    end
end
