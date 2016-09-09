module FakeDestroy
  def self.included(base)
    base.instance_eval do
      scope :active, -> { where('deleted_at IS NULL') }
      scope :deleted, -> { where('deleted_at IS NOT NULL') }
      alias_method_chain :destroy, :fake
    end
  end

  def destroy_with_fake(really = false)
    if really
      destroy_without_fake
    else
      self.deleted_at = Time.now
      run_callbacks(:destroy) do
        save!
      end
    end
  end

  def deleted?
    deleted_at
  end

  def undelete!
    self.deleted_at = nil
    save!
  end
end
