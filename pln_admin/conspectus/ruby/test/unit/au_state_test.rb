require File.dirname(__FILE__) + '/../test_helper'

class AuStateTest < ActiveSupport::TestCase
  
  def test_state_transitions
        
    all = AuState.find(:all); 
    irreversibles = AuState.irreversibles(); 
    reversibles = AuState.reversibles();
    #AuState.put_cached
    assert(!irreversibles.empty?)
    assert(!reversibles.empty?)
    
    puts ">>> transition table super user can do it all";
    for from in all do 
      for to in all do 
        allow = from.allow_transition_to(to, true); 
        puts "super_user trans #{from.name} (#{from.level})\t-> #{to.name} (#{from.level})\t== #{allow ? "yes" : "no"}\n"; 
        assert(allow);
      end
    end
    
    
    puts "\n>>> transition table regular user";
    for from in reversibles do 
      for to in reversibles do 
        allow = from.allow_transition_to(to, false); 
        puts "regular_user trans #{from.name}\t-> #{to.name}\t== #{allow ? "yes" : "no"}\n"; 
        assert(allow)
      end 
      for to in irreversibles do 
        allow = from.allow_transition_to(to, false); 
        puts "regular_user trans #{from.name}\t-> #{to.name}\t== #{allow ? "yes" : "no"}\n"; 
        assert(!allow)
      end
    end
    for from in irreversibles do 
      for to in all do 
        yes_on_retest = ((to == AuState.get("retest")) && from == AuState.get("preserved")) ||
                        ((to == AuState.get("preserved")) && from == AuState.get("retest"));
                        
        allow = from.allow_transition_to(to, false); 
        puts "regular_user trans #{from.name}\t-> #{to.name}\t== #{allow ? "yes" : "no"}\n"; 
        assert((allow == yes_on_retest) || (from == to))
      end 
    end 
  end
  
end 
