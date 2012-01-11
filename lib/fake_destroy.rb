module FakeDestroy
  def self.included(base)
    base.instance_eval do
      scope :active, where("deleted_at IS NULL")
      scope :deleted, where("deleted_at IS NOT NULL")
      alias_method_chain :destroy, :fake
    end
  end

  def destroy_with_fake(really = false)
    if really then destroy_without_fake else update_attribute(:deleted_at, Time.now) end
  end

  def deleted?
    self.deleted_at
  end

  def undelete!
    update_attribute(:deleted_at, nil)
  end
end
