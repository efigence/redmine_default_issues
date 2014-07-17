module DefaultIssuesHelper
  
  def default_issue_list(default_issues, &block)
    ancestors = []
    default_issues.each do |default_issue|
      while (ancestors.any? && !default_issue.is_descendant_of?(ancestors.last))
        ancestors.pop
      end
      yield default_issue, ancestors.size
      ancestors << default_issue unless default_issue.leaf?
    end
  end

  def default_issue_heading(default_issue)
    h("#{default_issue.tracker} ##{default_issue.id}")
  end
  
  def render_default_issue_subject_with_tree(default_issue)
    s = ''
    ancestors = default_issue.root? ? [] : default_issue.ancestors.visible.all
    ancestors.each do |ancestor|
      s << '<div>' + content_tag('p', link_to_default_issue(ancestor, :project => (default_issue.project_id != ancestor.project_id)))
    end
    s << '<div>'
    subject = h(default_issue.subject)
    #if default_issue.is_private?
    #   subject = content_tag('span', l(:field_is_private), :class => 'private') + ' ' + subject
    #end
    s << content_tag('h3', subject)
    s << '</div>' * (ancestors.size + 1)
    s.html_safe
  end

  class DefaultIssueFieldsRows
    include ActionView::Helpers::TagHelper

    def initialize
      @left = []
      @right = []
    end

    def left(*args)
      args.any? ? @left << cells(*args) : @left
    end

    def right(*args)
      args.any? ? @right << cells(*args) : @right
    end

    def size
      @left.size > @right.size ? @left.size : @right.size
    end

    def to_html
      html = ''.html_safe
      blank = content_tag('th', '') + content_tag('td', '')
      size.times do |i|
        left = @left[i] || blank
        right = @right[i] || blank
        html << content_tag('tr', left + right)
      end
      html
    end

    def cells(label, text, options={})
      content_tag('th', "#{label}:", options) + content_tag('td', text, options)
    end
  end

  def default_issue_fields_rows
    r = DefaultIssueFieldsRows.new
    yield r
    r.to_html
  end

  def link_to_default_issue(default_issue, options={})
    title = nil
    subject = nil
    text = options[:tracker] == false ? "##{default_issue.id}" : "#{default_issue.tracker} ##{default_issue.id}"
    if options[:subject] == false
      title = default_issue.subject.truncate(60)
    else
      subject = default_issue.subject
      if truncate_length = options[:truncate]
        subject = subject.truncate(truncate_length)
      end
    end
    only_path = options[:only_path].nil? ? true : options[:only_path]
    s = link_to(text, project_default_issue_path(@project, default_issue, :only_path => only_path),
                :class => default_issue.css_classes, :title => title)
    s << h(": #{subject}") if subject
    s = h("#{default_issue.project} - ") + s if options[:project]
    s
  end
end
