# frozen_string_literal: true

module IssueFeature
  private

  def issue_feature(issue, bbox = nil)
    geom = bbox.to_geometry if bbox
    creator_name = if policy(issue.created_by.profile).show?
                     issue.created_by.name
                   else
                     issue.created_by.display_name_or_anon
                   end
    creator_url = if policy(issue.created_by.profile).show?
                    view_context.url_for user_profile_path(issue.created_by)
                  else
                    "#"
                  end

    issue.loc_feature(thumbnail: issue.medium_icon_path,
                      anchor: issue.medium_icon_anchor,
                      image_url: issue.tip_icon_path,
                      title: issue.title,
                      size_ratio: issue.size_ratio(geom),
                      url: view_context.url_for(issue),
                      created_by: creator_name,
                      created_by_url: creator_url)
  end
end

