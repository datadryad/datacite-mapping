require 'spec_helper'

module Datacite
  module Mapping
    describe GeoLocationPoint do
      describe '#initialize' do
        it 'accepts a lat/long pair' do
          point = GeoLocationPoint.new(47.61, -122.33)
          expect(point.latitude).to eq(47.61)
          expect(point.longitude).to eq(-122.33)
        end

        it 'accepts :latitude and :longitude' do
          point = GeoLocationPoint.new(latitude: 47.61, longitude: -122.33)
          expect(point.latitude).to eq(47.61)
          expect(point.longitude).to eq(-122.33)
        end

        it 'requires both latitude and longitude' do
          expect { GeoLocationPoint.new(47.61) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(latitude: 47.61) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(longitude: -122.33) }.to raise_error(ArgumentError)
        end

        it 'rejects extra array arguments' do
          expect { GeoLocationPoint.new(47.61, -122.33, -70.67) }.to raise_error(ArgumentError)
        end

        it 'rejects extra hash arguments' do
          expect { GeoLocationPoint.new(latitude: 47.61, longitude: -122.33, south_latitude: -70.67) }.to raise_error(ArgumentError)
        end

        it 'rejects bad values' do
          expect { GeoLocationPoint.new(91, -122.33) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(-91, -122.33) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(47.61, 181) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(47.61, -181) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(latitude: 91, longitude: -122.33) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(latitude: -91, longitude: -122.33) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(latitude: 47.61, longitude: 181) }.to raise_error(ArgumentError)
          expect { GeoLocationPoint.new(latitude: 47.61, longitude: -181) }.to raise_error(ArgumentError)
        end
      end

      describe '#latitude=' do
        it 'sets the latitude' do
          point = GeoLocationPoint.allocate
          point.latitude = 47.61
          expect(point.latitude).to eq(47.61)
        end
        it 'requires a value' do
          point = GeoLocationPoint.allocate
          expect { point.latitude = nil }.to raise_error(ArgumentError)
        end
        it 'rejects bad values' do
          point = GeoLocationPoint.allocate
          expect { point.latitude = 91 }.to raise_error(ArgumentError)
          expect { point.latitude = -91 }.to raise_error(ArgumentError)
        end
      end

      describe '#longitude=' do
        it 'sets the longitude' do
          point = GeoLocationPoint.allocate
          point.longitude = 47.61
          expect(point.longitude).to eq(47.61)
        end
        it 'requires a value' do
          point = GeoLocationPoint.allocate
          expect { point.longitude = nil }.to raise_error(ArgumentError)
        end
        it 'rejects bad values' do
          point = GeoLocationPoint.allocate
          expect { point.longitude = 181 }.to raise_error(ArgumentError)
          expect { point.longitude = -181 }.to raise_error(ArgumentError)
        end
      end

      describe '#==' do
        it 'reports equal values as equal' do
          point1 = GeoLocationPoint.new(-33.45, -122.33)
          point2 = GeoLocationPoint.new(
            latitude: -33.45,
            longitude: -122.33
          )
          expect(point1).to eq(point2)
          expect(point2).to eq(point1)
        end
        it 'reports unequal values as unequal' do
          point1 = GeoLocationPoint.new(-47.61, -70.67)
          point2 = GeoLocationPoint.new(-33.45, -122.33)
          expect(point1).not_to eq(point2)
          expect(point2).not_to eq(point1)
        end
      end

      describe '#hash' do
        it 'reports equal values as having equal hashes' do
          point1 = GeoLocationPoint.new(-33.45, -122.33)
          point2 = GeoLocationPoint.new(
            latitude: -33.45,
            longitude: -122.33
          )
          expect(point1.hash).to eq(point2.hash)
          expect(point2.hash).to eq(point1.hash)
        end
        it 'reports unequal values as having unequal hashes' do
          point1 = GeoLocationPoint.new(-47.61, -70.67)
          point2 = GeoLocationPoint.new(-33.45, -122.33)
          expect(point1.hash).not_to eq(point2.hash)
          expect(point2.hash).not_to eq(point1.hash)
        end
      end

      describe '#to_s' do
        it 'returns the coordinates' do
          point = GeoLocationPoint.new(-33.45, -122.33)
          expect(point.to_s).to eq('-33.45 -122.33')
        end
      end
    end

    describe GeoLocationPointNode do

      class SomeElement
        include XML::Mapping
      end

      describe '#to_value' do
        it 'parses the value' do
          node = GeoLocationPointNode.new(SomeElement, :point, 'point')
          xml_text = '-33.45 -122.33'
          expected = GeoLocationPoint.new(-33.45, -122.33)
          expect(node.to_value(xml_text)).to eq(expected)
        end
        it 'deals with weird whitespace' do
          node = GeoLocationPointNode.new(SomeElement, :point, 'point')
          xml_text = %(
                        -33.45\t-122.33
                     )
          expected = GeoLocationPoint.new(-33.45, -122.33)
          expect(node.to_value(xml_text)).to eq(expected)
        end
      end

      it 'parses a Datacite 4 point' do
        xml_text = File.read('spec/data/datacite4/datacite-example-full-v4.0.xml')
        resource = Resource.parse_xml(xml_text)
        locs = resource.geo_locations
        expect(locs.size).to eq(1)
        loc = locs[0]
        point = loc.point
        expect(point).to be_a(GeoLocationPoint)
        expect(point.latitude).to eq(31.233)
        expect(point.longitude).to eq(-67.302)
      end

      it 'writes a Datacite 4 point'
    end

  end
end
