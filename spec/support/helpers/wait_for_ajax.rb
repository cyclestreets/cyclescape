# frozen_string_literal: true

module WaitForAjax
  def wait_for_ajax
    sleep 0.5
    sleep 0.05 while page.evaluate_script("jQuery.active").positive?
  end
end
