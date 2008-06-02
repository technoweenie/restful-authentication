module SecurityComponents
  def self.req_name(*args)
    File.join *args.flatten.map(&:to_s).map(&:underscore)
  end

  def self.req_subreqs(root, leaves)
    [req_name(root)] +
      leaves.map{ |leaf| req_name(root, leaf) }
  end

  # flatten the tree
  def self.walk_reqs(*trees)
    return [] if trees.blank?
    trees.map do |tree|
      case
      when tree.is_a?(Array) then walk_reqs *tree
      when tree.is_a?(Hash)  then tree.map{ |root, subtree| req_subreqs(root, walk_reqs(*subtree)) }.sum
      else                        [tree.to_s]
      end
    end.sum
  end
end

def security_components(*args)
  SecurityComponents.walk_reqs(args).each do |concern|
    # require_dependency concern.to_s # causes double includes ??
    include            concern.to_s.camelize.constantize
  end
end
