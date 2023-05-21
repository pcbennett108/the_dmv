require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
    @facility_1 = Facility.new({name: 'Albany DMV Office', address: '2242 Santiam Hwy SE Albany OR 97321', phone: '541-967-2014' })
    @facility_2 = Facility.new({name: 'Ashland DMV Office', address: '600 Tolman Creek Rd Ashland OR 97520', phone: '541-776-6092' })
    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
    @registrant_1 = Registrant.new('Bruce', 18, true )
    @registrant_2 = Registrant.new('Penny', 16 )
    @registrant_3 = Registrant.new('Tucker', 15 )
  end
  describe '#initialize' do
    it 'can initialize' do
      expect(@facility_1).to be_an_instance_of(Facility)
      expect(@facility_1.name).to eq('Albany DMV Office')
      expect(@facility_1.address).to eq('2242 Santiam Hwy SE Albany OR 97321')
      expect(@facility_1.phone).to eq('541-967-2014')
      expect(@facility_1.services).to eq([])
    end
  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility_1.services).to eq([])
      @facility_1.add_service('New Drivers License')
      @facility_1.add_service('Renew Drivers License')
      @facility_1.add_service('Vehicle Registration')
      expect(@facility_1.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end

    it 'starts with no fees or vehicles' do
      expect(@facility_1.registered_vehicles).to eq([])
      expect(@facility_1.collected_fees).to eq(0)
    end
  end

  describe '#register vehicle' do
    it 'can register vehicles with fees' do
      expect(@facility_1.services).to eq([])
      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.registered_vehicles).to eq([])
      expect(@facility_1.collected_fees).to eq(0)
      @facility_1.add_service('Vehicle Registration')
      expect(@facility_1.services).to eq(['Vehicle Registration'])
      expect(@facility_1.registered_vehicles).to eq([])
      @facility_1.register_vehicle(@cruz)
      expect(@facility_1.registered_vehicles).to eq([@cruz])
      expect(@facility_1.collected_fees).to eq(100)
      @facility_1.register_vehicle(@camaro)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro])
      expect(@facility_1.collected_fees).to eq(125)
      @facility_1.register_vehicle(@bolt)
      expect(@facility_1.registered_vehicles).to eq([@cruz, @camaro, @bolt])
      expect(@facility_1.collected_fees).to eq(325)
    end
    
    it 'can set registration date on register' do
      @facility_1.add_service('Vehicle Registration')
      expect(@cruz.registration_date).to eq(nil)
      @facility_1.register_vehicle(@cruz)
      expect(@cruz.registration_date).to eq(Date.new(2023,1,12))
    end

    it 'can set vehicle plate type on register' do
      @facility_1.add_service('Vehicle Registration')
      expect(@cruz.plate_type).to eq(nil)
      expect(@bolt.plate_type).to eq(nil)
      expect(@camaro.plate_type).to eq(nil)

      @facility_1.register_vehicle(@cruz)
      @facility_1.register_vehicle(@bolt)
      @facility_1.register_vehicle(@camaro)

      expect(@cruz.plate_type).to eq(:regular)
      expect(@bolt.plate_type).to eq(:ev)
      expect(@camaro.plate_type).to eq(:antique)
    end

    it 'only some locations can register vehicles' do
      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.services).to eq([])
      expect(@facility_2.register_vehicle(@bolt)).to eq(nil)
      expect(@facility_2.registered_vehicles).to eq([])
      expect(@facility_2.collected_fees).to eq(0)
    end

  end

  describe '#written Test' do
    it 'will only provide service if added' do
      expect(@facility_1.services).to eq([])
      expect(@facility_1.administer_written_test(@registrant_1)).to eq(false)
    end
    
    it 'can check registrant status' do
      expect(@registrant_1.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      expect(@registrant_1.permit?).to eq(true)
    end
    
    it 'can administer written test' do
      @facility_1.add_service('Written Test')
      expect(@facility_1.services).to eq(['Written Test'])
      expect(@facility_1.administer_written_test(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    end
    
    xit 'can check if registrant is qualified' do
      @facility_1.add_service('Written Test')
      expect(@registrant_2.age).to eq(16)
      expect(@registrant_2.permit?).to eq(false)
      expect(@facility_1.administer_written_test(@registrant_2)).to eq(false)
      @registrant_2.earn_permit
      expect(@facility_1.administer_written_test(@registrant_2)).to eq(true)
      expect(@registrant_2.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    end

    xit 'can reject unqualified registrant' do
      @facility_1.add_service('Written Test')
      expect(@registrant_3.age).to eq(15)
      expect(@registrant_3.permit?).to eq(false)
      expect(@facility_1.administer_written_test(@registrant_3)).to eq(false)
      @registrant_3.earn_permit
      expect(@registrant_3.permit?).to eq(true)
      expect(@facility_1.administer_written_test(@registrant_3)).to eq(false)
      expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
    end
  end
  
  describe '#Road Test' do
    xit 'will selectively administer road test if service is added' do
      @facility_1.add_service('Written Test')
      expect(@facility_1.administer_road_test(@registrant_3)).to eq(false)
      @registrant_3.earn_permit
      expect(@facility_1.administer_road_test(@registrant_3)).to eq(false)
      expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      expect(@facility_1.administer_road_test(@registrant_1)).to eq(false)
      @facility_1.add_service('Road Test')
      expect(@facility_1.services).to eq(['Written Test', 'Road Test'])
      expect(@facility_1.administer_road_test(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
      expect(@facility_1.administer_road_test(@registrant_2)).to eq(true)
      expect(@registrant_2.license_data).to eq({:written=>true, :license=>true, :renewed=>false})
    end
  end
  
  describe '#Renew License' do
    xit 'will selectively renew license if service is added' do
      expect(@facility_1.renew_drivers_license(@registrant_1)).to eq(false)
      @facility_1.add_service('Written Test')
      @facility_1.add_service('Road Test')
      @facility_1.add_service('Renew License')
      expect(@facility_1.services).to eq(['Written Test', 'Road Test', 'Renew License'])
      expect(@facility_1.renew_drivers_license(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
      expect(@facility_1.renew_drivers_license(@registrant_3)).to eq(false)
      expect(@registrant_3.license_data).to eq({:written=>false, :license=>false, :renewed=>false})
      expect(@facility_1.renew_drivers_license(@registrant_2)).to eq(true)
      expect(@registrant_2.license_data).to eq({:written=>true, :license=>true, :renewed=>true})
    end
  end


end

