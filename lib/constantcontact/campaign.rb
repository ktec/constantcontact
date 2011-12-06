# http://developer.constantcontact.com/doc/manageCampaigns
module ConstantContact
  class Campaign < Base
    include Searchable
    include HasManyLists

    STATUS_VALUES                 = ['Draft', 'Running', 'Scheduled',  'Archive Pending', 'Archived', 'Close Pending', 'Closed', 'Sent']
    CAMPAIGN_TYPE_VALUES          = ['STOCK','CUSTOM']
    GREETING_NAME_VALUES          = ['FirstName', 'LastName', 'FirstAndLastName', 'None']
    YES_NO_VALUES                 = ['YES','NO']
    ARCHIVE_STATUS_VALUES         = ['Pending','Published']
    EMAIL_CONTENT_FORMAT_VALUES   = ['HTML', 'XHTML']

    EDITABLE      = [:name,:from_name,:from_email,:reply_to_email,:view_as_webpage,:view_as_webpage_link_text,:view_as_webpage_text,:permission_reminder,:permission_reminder_text,:greeting_salutation,:greeting_name,:greeting_string,:organization_name,:organization_address1,:organization_address2,:organization_address3,:organization_city,:organization_state,:organization_international_state,:organization_postal_code,:organization_country,:include_forward_email,:forward_email_link_text,:include_subscribe_link,:subscribe_link_text,:email_content_format,:email_content,:email_text_content,:contact_lists]
    NON_EDITABLE  = [:date,:last_edit_date,:last_run_date,:next_run_date,:status,:sent,:opens,:clicks,:bounces,:forwards,:opt_outs,:share_page_url,:campaign_type,:archive_status,:archive_url,:urls]

    schema do

      # You need to ensure to specify the correct value in <EmailContentFormat>
      # element.  If it is set to HTML, then the values in <EmailContent> will
      # be treated like HTML

      # If it is set to XHTML, then the values in <EmailContent> will be treated
      # like XHTML the same way it is treated in our UI, which means it will be 
      # subject to a more strict validation to ensure the XHTML is valid.  If it
      # is not valid, you will receive an error and the campaign will not be
      # created.  In addition, <TextContent> also must have some content in order
      # to create an XHTML campaign.  The content must be in valid XHTML format
      # and any text content you pass in must be enclosed by <Text></Text> tags.

      # <ViewAsWebpage>, <ViewAsWebpageLinkText> and <ViewAsWebpageText>
      # If <ViewAsWebpage> is set to 'YES', then values in <ViewAsWebpageLinkText>
      # and <ViewAsWebpageText> will be used, and a link to view the campaign as
      # a webpage will be included in the campaign.  If <ViewAsWebpage> is set to
      # 'NO', then values in the other two elements will be ignored.

      # <IncludeFowardEmail> and <ForwardEmailLinkText>
      # If <IncludeFowardEmail> is set to 'YES', then the value in
      # <ForwardEmailLinkText> will be used to insert a link in the campaign. 
      # This is the same as "Forward Email to Friend" feature in the UI.  If
      # <IncludeForwardEmail> is set to 'NO', then <FowardEmailLinkText> will
      # be ignored.

      # <IncludeSubscribeLink> and <SubscribeLinkText>
      # If <IncludeSubscribeLink> is set to 'YES', then the value in 
      # <SubscribeLinkText> will be used to insert a link in the forwarded email
      # for "Forward Email to Friend" feature in the UI.  If <IncludeSubscribeLink>
      # is set to 'NO', then <SubscribeLinkText> will be ignored.

    end

    # Setup defaults when creating a new object since
    # CC requires so many extraneous fields to be present
    # when creating a new Campaign.
    def initialize(attributes = {}, persisted = false)
      attributes = attributes[0] if attributes.kind_of? Array
      self.contact_lists = attributes.delete(:list_ids) if attributes.has_key? :list_ids 
      obj = super
      obj.set_defaults
      obj
    end

    def to_xml
      xml = Builder::XmlMarkup.new
      xml.tag!("Campaign", :xmlns => "http://ws.constantcontact.com/ns/1.0/") do
        self.attributes.reject {|k,v| ['FromEmail','ReplyToEmail','ContactList'].include?(k)}.each{|k, v| xml.tag!( k.to_s.camelize, v )}
        xml.tag!("ReplyToEmail") { 
          xml.tag!('Email', :id => self.reply_to_email.id )
          xml.tag!('EmailAddress', self.reply_to_email) 
        }
        xml.tag!("FromEmail") { 
          xml.tag!('Email', :id => self.reply_to_email.id ) 
          xml.tag!('EmailAddress', self.reply_to_email) 
        }
        xml.tag!("ContactLists") do
          self.contact_lists.each do |list|
            xml.tag!("ContactList", :id=> list.url)
          end
        end
      end
    end

    # TODO - this needs some attention, we can't just go for the first account email
    # settings/emailaddresses is not a searchable resource either
    def from_email
      EmailAddress.find(:all).first
    end

    alias :reply_to_email :from_email
    alias :from_email :from_email

    protected

    def set_defaults

      defaults = {
        :from_name => self.class.user,
        :from_email => self.class.user,
        :greeting_salutation => 'Dear',
        :greeting_name => 'FirstName',
        :greeting_string => 'Greetings!',
        :status => 'DRAFT',
        :include_forward_email => 'NO',
        :organization_name => self.class.user,
        :date => "#{Time.now.strftime(DATE_FORMAT)}",
        :CampaignType => "CUSTOM",
        :ShowAgent => "false",
        :CampaignType => "CUSTOM",
        :PermissionReminder => "NO",
        :ViewAsWebpage => "NO",
        :Sent => "0",
        :Opens => "0",
        :Clicks => "0",
        :Bounces => "0",
        :Forwards => "0",
        :OptOuts => "0",
        :SpamReports => "0",
        :IncludeSubscribeLink => "NO"
      }
      update_attributes(defaults)

      # CampaignType
      # Since the API only supports creating a custom-code campaign, 
      # there is no reason to specify <CampaignType>, which will be ignored.

      # there are several elements that are required even though they are not used
      # by the server and are replaced upon a successful contact creation.  
      # These elements are <id>, <title>, <author>, and <updated> elements.
      # The <title> and <author> elements may be empty. The <id> must contain 
      # a URI, but since the value is not used by the server, any URI will work. 
      # The server does not check for uniqueness when creating a contact because a
      # new unique ID will be created anyway. The <updated> element must contain a
      # date or date/time value, but again the value is not used by the server.
      required = {
        :PermissionReminderText => "",
        :ViewAsWebpageLinkText => "",
        :ViewAsWebpageText => "",
        :ProductID => "",
        :LetterImageList => "",
        :LastEditDate => "",
        :StyleSheet => "",
        :OrganizationAddress1 => "",
        :OrganizationAddress2 => "",
        :OrganizationAddress3 => "",
        :OrganizationCity => "",
        :OrganizationState => "",
        :OrganizationInternationalState => "",
        :OrganizationPostalCode => "",
        :OrganizationCountry => "",
        :ForwardEmailLinkText => "",
        :SubscribeLinkText => "",
        :ArchiveStatus => "",
        :ArchiveURL => "",
        :SharePageURL => "",
        :NextRunDate => "",
        :Urls => ""
      }
      update_attributes(required, true)

    end

    def update_attributes(hash = {},overwrite=false)
      hash.each do |key,value|
        attributes["#{key.to_s.camelize}"] = value if overwrite or !attributes.has_key? key.to_s.camelize
      end
    end

    # prevent editing non-editable fields
    def method_missing(method_symbol, *arguments, &block) #:nodoc:
      method_name = method_symbol.to_s
      if method_name =~ /(=|\?)$/
        case $1
        when "="
          if NON_EDITABLE.include?(($`).underscore.to_sym)
            key = search_attributes($`)
            attributes[key] if attributes.has_key?(key)
          else
            restricted_values = get_restricted_values?($`) 
            if restricted_values.include?($`)
              attributes[search_attributes($`)] = arguments.first
            else
              raise ArgumentError, "Value must be one of #{restricted_values}" 
            end
          end
        end
      else
        super
      end
    end

    def get_restricted_values?(attribute)
      const = "#{attribute.underscore.upcase}_VALUES".to_sym
      if Campaign::const_defined?(const)
        Campaign::const_get(const)
      else
        [attribute]
      end
    end

    # Formats data if present.
    def before_save
      self.email_text_content = "<Text>#{email_text_content}</Text>" unless email_text_content.match /^\<Text/
      self.date               = self.date.strftime(DATE_FORMAT) if attributes.has_key?('Date') && self.date.is_a?(Time)
    end


    def validate
      # NOTE: Needs to be uppercase!
      unless attributes.has_key?('EmailContentFormat') && ['HTML', 'XHTML'].include?(email_content_format)
        errors.add(:email_content_format, 'must be either HTML or XHTML (the latter for advanced email features)')
      end

      if attributes.has_key?('ViewAsWebpage') && view_as_webpage.downcase == 'yes'
        unless attributes['ViewAsWebpageLinkText'].present? && attributes['ViewAsWebpageText'].present?
          errors.add(:view_as_webpage, "You need to set view_as_webpage_link_text and view_as_webpage_link if view_as_webpage is YES")
        end
      end

      errors.add(:email_content, 'cannot be blank') unless attributes.has_key?('EmailContent')
      errors.add(:email_text_content, 'cannot be blank') unless attributes.has_key?('EmailTextContent')
      errors.add(:name, 'cannot be blank') unless attributes.has_key?('Name')
      errors.add(:subject, 'cannot be blank') unless attributes.has_key?('Subject')
    end

    class << self

    end


  end
end
