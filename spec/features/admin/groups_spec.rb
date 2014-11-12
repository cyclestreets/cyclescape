require 'spec_helper'

describe 'Groups admin' do
  include_context 'signed in as admin'

  let!(:groups) { FactoryGirl.create_list(:group, 5) }

  before do
    visit admin_groups_path
  end

  context 'index' do
    it 'should list all the groups' do
      groups.should_not be_empty
      groups.each do |g|
        page.should have_content(g.name)
      end
    end
  end

  context 'new' do
    before do
      click_link I18n.t('.admin.groups.index.new_group')
    end

    it 'should let you create a new group' do
      fill_in 'Name', with: 'Placeford Cycling'
      fill_in 'Subdomain', with: 'placefordcc'
      fill_in 'Website', with: 'http://www.placefordcc.com'
      click_on 'Create Group'
      Group.where("name = 'Placeford Cycling'").count.should == 1
      current_path.should == admin_groups_path
      page.should have_content('Placeford Cycling')
    end
  end

  context 'edit' do
    let(:group) { groups.first }

    before do
      within('table tr:first') do
        click_on 'Edit', match: :first
      end
    end

    it 'should show the current group details' do
      page.should have_field('Name', with: group.name)
      page.should have_field('Subdomain', with: group.short_name)
      page.should have_field('Website', with: group.website)
    end

    it 'should update the group' do
      fill_in 'Name', with: 'Placeford Cycling Campaign'
      click_on 'Save'
      page.current_path.should == admin_groups_path
      page.should have_content('Placeford Cycling Campaign')
    end
  end
end
