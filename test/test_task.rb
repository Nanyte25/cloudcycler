require 'cloud/cycler/task'

class TestTasks < Minitest::Test
  def setup
    @task = Cloud::Cycler::Task.new(MockCycler.new, 'dummy-task')
    @test_stacks = [
      'test-1-staging', 'test-1-uat', 'test-1-prod',
      'test-2-staging', 'test-2-uat', 'test-2-prod',
      'test-3-staging', 'test-3-uat', 'test-3-prod',
    ]
    @test_instances = [
      'i-00000011',
      'i-00000012',
      'i-00000013',
      'i-00000021',
      'i-00000022',
      'i-00000023',
      'i-00000031',
      'i-00000032',
      'i-00000033',
    ]
  end

  def include_strings(type)
    case type
    when :cfn
      @task.include(:cfn, 'test-1-staging')
      @task.include(:cfn, 'test-2-staging')
      @task.include(:cfn, 'test-3-staging')
    when :ec2
      @task.include(:ec2, 'i-00000011')
      @task.include(:ec2, 'i-00000021')
      @task.include(:ec2, 'i-00000031')
    end
  end

  def include_regex(type)
    case type
    when :cfn
      @task.include(:cfn, /test-\d-staging/)
    when :ec2
      @task.include(:ec2, /i-000000\d\d/)
    end
  end

  def exclude_string(type)
    case type
    when :cfn
      @task.exclude(:cfn, 'test-2-staging')
    when :ec2
      @task.exclude(:ec2, 'i-00000021')
    end
  end

  def exclude_regex(type)
    case type
    when :cfn
      @task.exclude(:cfn, /^test-2/)
    when :ec2
      @task.exclude(:ec2, /21$/)
    end
  end

  def assert_includes_for(type)
    case type
    when :cfn
      assert_includes(@task.includes[:cfn], 'test-1-staging')
      assert_includes(@task.includes[:cfn], 'test-2-staging')
      assert_includes(@task.includes[:cfn], 'test-3-staging')
    when :ec2
      assert_includes(@task.includes[:ec2], 'i-00000011')
      assert_includes(@task.includes[:ec2], 'i-00000021')
      assert_includes(@task.includes[:ec2], 'i-00000031')
    end
  end

  def assert_includes_excludes_for(type)
    case type
    when :cfn
      assert_includes(@task.includes[:cfn], 'test-1-staging')
      refute_includes(@task.includes[:cfn], 'test-2-staging')
      assert_includes(@task.includes[:cfn], 'test-3-staging')
    when :ec2
      assert_includes(@task.includes[:ec2], 'i-00000011')
      refute_includes(@task.includes[:ec2], 'i-00000021')
      assert_includes(@task.includes[:ec2], 'i-00000031')
    end
  end

  def assert_exclude_for(type)
    case type
    when :cfn
      assert @task.excluded?(:cfn, 'test-2-staging')
    when :ec2
      assert @task.excluded?(:ec2, 'i-00000021')
    end
  end

  def stub_cache_for(type, &block)
    case type
    when :cfn
      @task.stub(:cfn_cache, @test_stacks, &block)
    when :ec2
      @task.stub(:ec2_cache, @test_instances, &block)
    end
  end

  def stub_method(name, type, &block)
    define_method("#{name}_#{type}") do
      stub_cache_for(type, &block)
    end
  end

  [:cfn, :ec2].each do |type|
    define_method("test_include_strings_#{type}") do
      stub_cache_for(type) do
        include_strings(type)
        assert_includes_for(type)
      end
    end

    define_method("test_include_regex_#{type}") do
      stub_cache_for(type) do
        include_regex(type)
        assert_includes_for(type)
      end
    end

    define_method("test_exclude_string_#{type}") do
      stub_cache_for(type) do
        exclude_string(type)
        assert_exclude_for(type)
      end
    end

    define_method("test_exclude_regex_#{type}") do
      stub_cache_for(type) do
        exclude_regex(type)
        assert_exclude_for(type)
      end
    end

    define_method("test_exclude_string_before_strings_#{type}") do
      stub_cache_for(type) do
        exclude_string(type)
        include_strings(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_string_before_regex_#{type}") do
      stub_cache_for(type) do
        exclude_string(type)
        include_regex(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_string_after_strings_#{type}") do
      stub_cache_for(type) do
        include_strings(type)
        exclude_string(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_string_after_regex_#{type}") do
      stub_cache_for(type) do
        include_regex(type)
        exclude_string(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_regex_before_strings_#{type}") do
      stub_cache_for(type) do
        exclude_regex(type)
        include_strings(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_regex_before_regex_#{type}") do
      stub_cache_for(type) do
        exclude_regex(type)
        include_regex(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_regex_after_strings_#{type}") do
      stub_cache_for(type) do
        include_strings(type)
        exclude_regex(type)
        assert_includes_excludes_for(type)
      end
    end

    define_method("test_exclude_regex_after_regex_#{type}") do
      stub_cache_for(type) do
        include_regex(type)
        exclude_regex(type)
        assert_includes_excludes_for(type)
      end
    end
  end
end
