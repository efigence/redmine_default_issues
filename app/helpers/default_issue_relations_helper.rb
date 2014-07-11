module DefaultIssueRelationsHelper
  def collection_for_relation
    values = DefaultIssueRelation::TYPES
    values.keys.sort{|x,y| values[x][:order] <=> values[y][:order]}.collect{|k| [l(values[k][:name]), k]}
  end
end
