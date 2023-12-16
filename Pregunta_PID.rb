class CurrentDay
    def initialize
      @date = Date.today
      @schedule = MonthlySchedule.new(@date.year,@date.month)
    end
    def work_hours
      @schedule.work_hours_for(@date)
    end
    def workday?
      !@schedule.holidays.include?(@date)
    end
end

before do
    Date.singleton_class.class_eval do
        alias_method :_today, :today
        define_method(:today){Date.new(2020, 12, 16)}
    end
end
after do
    Date.singleton_class.class_eval do
        alias_method :today, :_today
        remove_method :_today
    end	
end

