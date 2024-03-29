# coding: utf-8
require 'spec_helper'



describe Ajax::Helpers::UrlHelper do
  DOMAINS = %w[musicsocial.com.local altnet.com amusicstreamingservice.com stage.altnet.com rails1.creagency.com.au]

  describe "url_fragment" do
    it "should return the fragment" do
      Ajax.url_fragment('/Beyonce#abc').should == 'abc'
      Ajax.url_fragment('/Beyonce#/abc').should == '/abc'
      Ajax.url_fragment('/Beyonce#/abc').should == '/abc'
    end
  end

  describe "normalized_url_fragment" do
    it "should return the fragment" do
      Ajax.normalized_url_fragment('/Beyonce#abc').should == '/abc'
      Ajax.normalized_url_fragment('/Beyonce#/abc').should == '/abc'
      Ajax.normalized_url_fragment('/Beyonce#/abc').should == '/abc'
      Ajax.normalized_url_fragment('/Beyonce#!/abc').should == '/abc'
      Ajax.normalized_url_fragment('/Beyonce#!//abc').should == '/abc'
      Ajax.normalized_url_fragment('/Beyonce#!/?abc').should == '/?abc'
      Ajax.normalized_url_fragment('/Beyonce#/!/abc').should == '/!/abc'
    end
  end

  [[false, '/#/'], [true, '/#!/']].each do |crawlable, fragment|
    describe "when #{crawlable ? 'not' : ''} google crawlable" do
      before :all do
        @original ||= set_option(:crawlable => crawlable)
      end

      after :all do
        set_option(:crawlable => @original.first)
      end

      describe "hashed_url_from_traditional" do
        it "should handle a query string" do
          Ajax.hashed_url_from_traditional('/Beyonce?one=1').should == fragment + 'Beyonce?one=1'
        end

        it "should ignore the fragment" do
          Ajax.hashed_url_from_traditional('/Beyonce?one=1#fragment').should == fragment + 'Beyonce?one=1'
        end

        it "should handle no query string" do
          Ajax.hashed_url_from_traditional('/Beyonce').should == fragment + 'Beyonce'
        end

        it "should handle special characters" do
          Ajax.hashed_url_from_traditional('/beyoncé').should == fragment + 'beyonc%C3%A9'
          Ajax.hashed_url_from_traditional('/red hot').should == fragment + 'red%20hot'
        end

        DOMAINS.each do |domain|
          it "should work for domain #{domain}" do
            Ajax.hashed_url_from_traditional("http://#{domain}/playlists").should == "http://#{domain}#{fragment}playlists"
          end
        end
      end

      describe "hashed_url_from_fragment" do
        it "should strip double slashes" do
          Ajax.hashed_url_from_fragment('/Beyonce#/Akon').should == fragment + 'Akon'
          Ajax.hashed_url_from_fragment('/Beyonce#Akon').should == fragment + 'Akon'
        end

        it "should handle special characters" do
          Ajax.hashed_url_from_fragment('/#/beyoncé').should == fragment + 'beyonc%C3%A9'
          Ajax.hashed_url_from_fragment('/#/red hot').should == fragment + 'red%20hot'
        end

        it "should handle special characters" do
          Ajax.hashed_url_from_fragment('/#!/beyoncé').should == fragment + 'beyonc%C3%A9'
          Ajax.hashed_url_from_fragment('/#!/red hot').should == fragment + 'red%20hot'
        end

        it "should handle no fragment" do
          Ajax.hashed_url_from_fragment('/Beyonce').should == fragment
        end

        DOMAINS.each do |domain|
          it "should work for domain #{domain}" do
            Ajax.hashed_url_from_fragment("http://#{domain}").should == "http://#{domain}#{fragment}"
            Ajax.hashed_url_from_fragment("http://#{domain}/").should == "http://#{domain}#{fragment}"
            Ajax.hashed_url_from_fragment("http://#{domain}/Beyonce/#/playlists").should == "http://#{domain}#{fragment}playlists"
            Ajax.hashed_url_from_fragment("http://#{domain}/Beyonce/#!/playlists").should == "http://#{domain}#{fragment}playlists"
          end
        end
      end
    end
  end

  describe "url_is_root?" do
    it "should detect root urls" do
      Ajax.url_is_root?('/#/Beyonce?query2').should be(true)
      Ajax.url_is_root?('/#!/Beyonce?query2').should be(true)
      Ajax.url_is_root?('/').should be(true)
      Ajax.url_is_root?('/#/beyoncé'). should be(true)
      Ajax.url_is_root?('/#!/beyoncé'). should be(true)
    end

    it "should detect non-root urls" do
      Ajax.url_is_root?('/Beyonce').should be(false)
    end

    it "should support full URLs" do
      Ajax.is_hashed_url?('http://musicsocial.com.local/#/playlists').should be(true)
      Ajax.is_hashed_url?('http://musicsocial.com.local/#!/playlists').should be(true)
    end

    it "should support special characters" do
      Ajax.is_hashed_url?('http://musicsocial.com.local/#/beyoncé').should be(true)
      Ajax.is_hashed_url?('http://musicsocial.com.local/#!/beyoncé').should be(true)
    end
  end

  describe "is_hashed_url?" do
    it "should return false for fragments that don't start with /" do
      Ajax.is_hashed_url?('/Beyonce#Akon').should be(false)
      Ajax.is_hashed_url?('/Beyonce?query#Akon/').should be(false)
      Ajax.is_hashed_url?('/Beyonce?query%23').should be(false)
    end

    it "should return true if the fragment starts with /" do
      Ajax.is_hashed_url?('/Beyonce#/Akon').should be(true)
      Ajax.is_hashed_url?('/#/Akon').should be(true)
      Ajax.is_hashed_url?('/Beyonce?query%23/').should be(true) # KJV technically I don't think this behaviour is correct
    end

    it "should return true if the fragment starts with !" do
      Ajax.is_hashed_url?('/Beyonce#!Akon').should be(true)
      Ajax.is_hashed_url?('/#!/Akon').should be(true)
      Ajax.is_hashed_url?('/Beyonce?query%23!/').should be(true) # KJV technically I don't think this behaviour is correct
    end

    DOMAINS.each do |domain|
      it "should work for domain #{domain}" do
        Ajax.is_hashed_url?("http://#{domain}/#/playlists").should be(true)
        Ajax.is_hashed_url?("http://#{domain}/#!/playlists").should be(true)
        Ajax.is_hashed_url?("http://#{domain}/playlists").should be(false)
      end
    end
  end

  describe "traditional_url_from_fragment" do
    it "should handle slashes" do
      Ajax.traditional_url_from_fragment('/Beyonce#Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#/Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#/Akon/').should == '/Akon/'
    end

    it "should handle slashes with !" do
      Ajax.traditional_url_from_fragment('/Beyonce#!Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#!/Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#!/Akon/').should == '/Akon/'
    end

    it "should handle no fragment" do
      Ajax.traditional_url_from_fragment('/Beyonce#/beyoncé').should == '/beyonc%C3%A9'
      Ajax.traditional_url_from_fragment('/#/red hot').should == '/red%20hot'
    end

    it "should handle no fragment with !" do
      Ajax.traditional_url_from_fragment('/Beyonce#!/beyoncé').should == '/beyonc%C3%A9'
      Ajax.traditional_url_from_fragment('/#!/red hot').should == '/red%20hot'
    end

    it "should handle special characters" do
      Ajax.traditional_url_from_fragment('/Beyonce#/Akon').should == '/Akon'
      Ajax.traditional_url_from_fragment('/Beyonce#!/Akon').should == '/Akon'
    end

    DOMAINS.each do |domain|
      it "should work for domain #{domain}" do
        Ajax.traditional_url_from_fragment("http://#{domain}/Beyonce/#playlists").should == "http://#{domain}/playlists"
        Ajax.traditional_url_from_fragment("http://#{domain}/Beyonce/#/playlists").should == "http://#{domain}/playlists"

        Ajax.traditional_url_from_fragment("http://#{domain}/Beyonce/#!playlists").should == "http://#{domain}/playlists"
        Ajax.traditional_url_from_fragment("http://#{domain}/Beyonce/#!/playlists").should == "http://#{domain}/playlists"
      end
    end
  end
end

