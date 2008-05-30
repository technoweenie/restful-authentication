# -*- coding: mule-utf-8 -*-
require File.dirname(__FILE__) + '<%= ('/..'*model_controller_class_nesting_depth) + '/../spec_helper' %>'

describe <%= class_name %> do
  #
  # Validations
  #
  field_validity = {
    :login => {
      :valid   => ['123', '1234567890_234567890_234567890_234567890', 'hello.-_there@funnychar.com'],
      :invalid => [nil, '', '12', '1234567890_234567890_234567890_234567890_', "tab\t", "newline\n",
        "Iñtërnâtiônàlizætiøn hasn't happened to ruby 1.8 yet",
        'semicolon;', 'quote"', 'tick\'', 'backtick`', 'percent%', 'plus+', 'space ']},
    :email => {
      :valid   => ['foo@bar.com', 'foo@newskool-tld.museum', 'foo@twoletter-tld.de', 'foo@nonexistant-tld.qq',
        'r@a.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail.com',
        'hello.-_there@funnychar.com', 'uucp%addr@gmail.com', 'hello+routing-str@gmail.com',
        'domain@can.haz.many.sub.doma.in',],
      :invalid => [nil, '', '!!@nobadchars.com', 'foo@no-rep-dots..com', 'foo@badtld.xxx', 'foo@toolongtld.abcdefg',
        'Iñtërnâtiônàlizætiøn@hasnt.happened.to.email', 'need.domain.and.tld@de', "tab\t", "newline\n",
        'r@.wk', '1234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890-234567890@gmail2.com',
        # these are technically allowed but not seen in practice:
        'uucp!addr@gmail.com', 'semicolon;@gmail.com', 'quote"@gmail.com', 'tick\'@gmail.com', 'backtick`@gmail.com', 'space @gmail.com', 'bracket<@gmail.com', 'bracket>@gmail.com'],},
    :name => {
      :valid   => ['', 'Andre The Giant (7\'4", 520 lb.) -- has a posse',
        '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890',],
      :invalid => ["tab\t", "newline\n",
        '1234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_234567890_',]},
  }

  describe 'being created' do
    describe 'validates correctly' do
      field_validity.each do |attr, vals|
        vals[:valid].each do |val|
          it "is valid for #{attr} = '#{val}'"   do
            @user = create_user(attr => val);
            is_valid_and_saves @user, (attr==:password ? [] : {attr => val})
          end
        end
        vals[:invalid].each do |val|
          it "is invalid for #{attr} = '#{val}'" do
            @user = create_user(attr => val);
            is_not_valid_and_does_not_save @user
          end
        end
      end
    end
  end
end
