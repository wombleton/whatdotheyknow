require File.dirname(__FILE__) + '/../spec_helper'

 describe PublicBody, "making up the URL name" do 
    before do
        @public_body = PublicBody.new
    end

    it 'should remove spaces, and make lower case' do 
        @public_body.name = 'Some Authority'
        @public_body.url_name.should == 'some_authority'
    end

    it 'should not allow a numeric name' do 
        @public_body.name = '1234'
        @public_body.url_name.should == 'body'
    end
end
 
describe PublicBody, " when saving" do
    before do
        @public_body = PublicBody.new 
    end

    it "should not be valid without setting some parameters" do
        @public_body.should_not be_valid
    end

    it "should not be valid with misformatted request email" do
        @public_body.name = "Testing Public Body"
        @public_body.short_name = "TPB"
        @public_body.request_email = "requestBOOlocalhost"
        @public_body.last_edit_editor = "*test*"
        @public_body.last_edit_comment = "This is a test"
        @public_body.should_not be_valid
        @public_body.should have(1).errors_on(:request_email)
    end

    it "should save" do
        @public_body.name = "Testing Public Body"
        @public_body.short_name = "TPB"
        @public_body.request_email = "request@localhost"
        @public_body.last_edit_editor = "*test*"
        @public_body.last_edit_comment = "This is a test"
        @public_body.save!
    end
end

describe PublicBody, "when searching" do
    fixtures :public_bodies, :public_body_versions

    it "should find by existing url name" do
        body = PublicBody.find_by_url_name_with_historic('dfh')
        body.id.should == 3
    end

    it "should find by historic url name" do
        body = PublicBody.find_by_url_name_with_historic('hdink')
        body.id.should == 3
        body.class.to_s.should == 'PublicBody'
    end

    it "should cope with not finding any" do
        body = PublicBody.find_by_url_name_with_historic('idontexist')
        body.should be_nil
    end

    it "should cope with duplicate historic names" do
        body = PublicBody.find_by_url_name_with_historic('dfh')

        # create history with short name "mouse" twice in it
        body.short_name = 'Mouse'
        body.url_name.should == 'mouse'
        body.save!
        body.request_email = 'dummy@localhost'
        body.save!
        # but a different name now
        body.short_name = 'Stilton'
        body.url_name.should == 'stilton'
        body.save!

        # try and find by it
        body = PublicBody.find_by_url_name_with_historic('mouse')
        body.id.should == 3
        body.class.to_s.should == 'PublicBody'
    end
end

describe PublicBody, " when loading CSV files" do
    it "should do a dry run successfully" do
        original_count = PublicBody.count

        csv_contents = load_file_fixture("fake-authority-type.csv")
        errors, notes = PublicBody.import_csv(csv_contents, 'fake', true, 'someadmin') # true means dry run
        errors.should == []
        notes.size.should == 3
        notes.should == ["line 1: new authority 'North West Fake Authority' with email north_west_foi@localhost", 
            "line 2: new authority 'Scottish Fake Authority' with email scottish_foi@localhost", 
            "line 3: new authority 'Fake Authority of Northern Ireland' with email ni_foi@localhost"]

        PublicBody.count.should == original_count
    end

    it "should do full run successfully" do
        original_count = PublicBody.count

        csv_contents = load_file_fixture("fake-authority-type.csv")
        errors, notes = PublicBody.import_csv(csv_contents, 'fake', false, 'someadmin') # false means real run
        errors.should == []
        notes.size.should == 3
        notes.should == ["line 1: new authority 'North West Fake Authority' with email north_west_foi@localhost", 
            "line 2: new authority 'Scottish Fake Authority' with email scottish_foi@localhost", 
            "line 3: new authority 'Fake Authority of Northern Ireland' with email ni_foi@localhost"]

        PublicBody.count.should == original_count + 3
    end
end



