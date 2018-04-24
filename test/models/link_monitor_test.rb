require 'test_helper'

class LinkMonitorTest < ActiveSupport::TestCase
  setup do
    @resource = events(:one)
  end

  test 'link monitor initialized with failure timestamp and count' do
    assert_difference('LinkMonitor.count') do
      @resource.create_link_monitor
    end

    assert @resource.link_monitor
    assert_not_nil @resource.link_monitor.failed_at
    assert_not_nil @resource.link_monitor.last_failed_at
    assert_not_nil @resource.link_monitor.fail_count
  end

  test 'link monitor success does not persist' do
    link_monitor = @resource.create_link_monitor

    link_monitor.success

    assert_equal 200, link_monitor.code
    assert_nil link_monitor.failed_at
    assert_nil link_monitor.last_failed_at

    link_monitor.reload

    refute_equal 200, link_monitor.code
  end

  test 'link monitor failure does not persist' do
    link_monitor = @resource.create_link_monitor
    link_monitor.update_column(:code, nil)
    link_monitor.update_column(:failed_at, nil)
    link_monitor.update_column(:last_failed_at, nil)
    link_monitor.update_column(:fail_count, 0)

    link_monitor.failure(404)

    assert_equal 404, link_monitor.code
    assert_not_nil link_monitor.failed_at
    assert_not_nil link_monitor.last_failed_at

    link_monitor.reload

    refute_equal 404, link_monitor.code
  end

  test 'link monitor success! does persist' do
    link_monitor = @resource.create_link_monitor

    link_monitor.success!
    link_monitor.reload

    assert_equal 200, link_monitor.code
    assert_nil link_monitor.failed_at
    assert_nil link_monitor.last_failed_at
  end

  test 'link monitor fail! does persist' do
    link_monitor = @resource.create_link_monitor
    link_monitor.update_column(:code, nil)
    link_monitor.update_column(:failed_at, nil)
    link_monitor.update_column(:last_failed_at, nil)
    link_monitor.update_column(:fail_count, 0)

    link_monitor.fail!(404)
    link_monitor.reload

    assert_equal 404, link_monitor.code
    assert_not_nil link_monitor.failed_at
    assert_not_nil link_monitor.last_failed_at
  end

  test 'link monitor failing?' do
    link_monitor = @resource.create_link_monitor

    refute link_monitor.failing?

    link_monitor.last_failed_at = Time.now
    link_monitor.failed_at = 5.days.ago

    assert link_monitor.failing?
  end
end
