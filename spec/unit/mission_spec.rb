require File.expand_path '../../spec_helper.rb', __FILE__

describe Mission do
  context 'Invalid instanciation' do
    let(:instance) { Mission.new }
    it { expect(instance).to be_a Mission }
    it { expect(instance).to_not be_valid }
  end
  context 'with description' do
    let(:instance) { create :mission, description: '_hello_' }
    it { expect(instance).to be_a Mission }
    describe 'reading it\'s description markup' do
      it do
        expect(GitHub::Markup).to receive(:render).with(kind_of(String), instance.read_attribute(:description)) { '<em>hello</em>' }
        instance.description_md
      end
    end
  end
  context 'with tasks' do
    let(:instance) { create :mission_with_tasks }
    it { expect(instance.tasks.count).to_not be_zero }
    context 'and at least one task closed' do
      it do
        expect {
          instance.tasks.first.update_attribute :closed, true
        }.to change{instance.progress}.from(0).to(20)
      end
    end
  end
end
