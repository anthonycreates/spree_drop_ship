require 'spec_helper'
require 'cancan/matchers'
require 'spree/testing_support/ability_helpers'

describe Spree::SupplierAbility do

  let(:user) { create(:user, supplier: create(:supplier)) }
  let(:ability) { Spree::SupplierAbility.new(user) }
  let(:token) { nil }

  context 'for Ckeditor::AttachmentFile' do
    let(:resource) { Ckeditor::AttachmentFile }

    context 'requested by another suppliers user' do
      let(:resource) { Ckeditor::AttachmentFile.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'create only'
    end

    context 'requested by suppliers user' do
      let(:resource) { Ckeditor::AttachmentFile.new({supplier: user.supplier}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Ckeditor::AttachmentFile' do
    let(:resource) { Ckeditor::Picture}

    context 'requested by another suppliers user' do
      let(:resource) { Ckeditor::Picture.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'create only'
    end

    context 'requested by suppliers user' do
      let(:resource) { Ckeditor::Picture.new({supplier: user.supplier}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Dash' do
    let(:resource) { Spree::Admin::OverviewController }

    context 'requested by supplier' do
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'admin denied'
    end
  end

  context 'for DropShipOrder' do
    let(:resource) { Spree::DropShipOrder }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by any user' do
      let(:ability) { Spree::SupplierAbility.new(create(:user)) }
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'admin denied'
    end

    context 'requested by another suppliers user' do
      let(:resource) { Spree::DropShipOrder.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::DropShipOrder.new({supplier: user.supplier}, without_protection: true) }

      it 'should be able to administer updates' do
        ability.should be_able_to :admin, resource
        ability.should be_able_to :confirm, resource
        ability.should_not be_able_to :create, resource
        ability.should_not be_able_to :destroy, resource
        ability.should be_able_to :read, resource
        ability.should be_able_to :update, resource
      end
    end
  end

  context 'for Image' do
    let(:resource) { Spree::Image }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:variant) { create(:variant, product: create(:product, supplier: create(:supplier))) }
      let(:resource) { Spree::Image.new({viewable_id: variant.id, viewable_type: variant.class.to_s}, without_protection: true) }
      it_should_behave_like 'create only'
    end

    context 'requested by suppliers user' do
      let(:variant) { create(:variant, product: create(:product, supplier: user.supplier)) }
      let(:resource) { Spree::Image.new({viewable_id: variant.id, viewable_type: variant.class.to_s}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for GroupPricing' do
    let(:resource) { Spree::GroupPrice.new }

    context 'requested by another suppliers user' do
      let(:resource) { Spree::GroupPrice.new({variant: create(:variant, product: create(:product, supplier: create(:supplier)))}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::GroupPrice.new({variant: create(:variant, product: create(:product, supplier: user.supplier))}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Product' do
    let(:resource) { Spree::Product }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::Product.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'create only'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::Product.new({supplier: user.supplier}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for ProductProperty' do
    let(:resource) { Spree::ProductProperty }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::ProductProperty.new({product: create(:product, supplier: create(:supplier))}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::ProductProperty.new({product: create(:product, supplier: user.supplier)}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Property' do
    let(:resource) { Spree::Property }

    it_should_behave_like 'admin granted'
    it_should_behave_like 'read only'
  end

  context 'for Prototype' do
    let(:resource) { Spree::Prototype }

    it_should_behave_like 'admin granted'
    it_should_behave_like 'read only'
  end

  context 'for Relation' do
    let(:resource) { Spree::Relation }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::Relation.new({relatable: create(:product, supplier: create(:supplier))}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::Relation.new({relatable: create(:product, supplier: user.supplier)}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Shipment' do
    context 'requested by another suppliers user' do
      let(:resource) { Spree::Shipment.new({stock_location: create(:stock_location, supplier: create(:supplier))}, without_protection: true) }
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'admin denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::Shipment.new({stock_location: create(:stock_location, supplier: user.supplier)}, without_protection: true) }
      it_should_behave_like 'access granted'
      it_should_behave_like 'index allowed'
      it_should_behave_like 'admin granted'
      it { ability.should be_able_to :ready, resource }
      it { ability.should be_able_to :ship, resource }
    end
  end

  context 'for StockItem' do
    let(:resource) { Spree::StockItem }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::StockItem.new({variant: create(:product, supplier: create(:supplier)).master}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::StockItem.new({variant: create(:product, supplier: user.supplier).master}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for StockLocation' do
    context 'requsted by another suppliers user' do
      let(:resource) { Spree::StockLocation.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::StockLocation.new({supplier: user.supplier}, without_protection: true) }
      it_should_behave_like 'access granted'
      it_should_behave_like 'admin granted'
      it_should_behave_like 'index allowed'
    end
  end

  context 'for StockMovement' do
    let(:resource) { Spree::StockMovement }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::StockMovement.new({stock_item: build(:stock_item, variant: create(:product, supplier: create(:supplier)).master)}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::StockMovement.new({stock_item: build(:stock_item, variant: create(:product, supplier: user.supplier).master)}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

  context 'for Supplier' do
    context 'requested by any user' do
      let(:ability) { Spree::SupplierAbility.new(create(:user)) }
      let(:resource) { Spree::Supplier }

      it_should_behave_like 'admin denied'

      context 'w/ DropShipConfig[:allow_signup] == false (the default)' do
        it_should_behave_like 'access denied'
      end

      context 'w/ DropShipConfig[:allow_signup] == true' do
        after do
          Spree::DropShipConfig.set allow_signup: false
        end
        before do
          Spree::DropShipConfig.set allow_signup: true
        end
        it_should_behave_like 'create only'
      end
    end

    context 'requested by suppliers user' do
      let(:resource) { user.supplier }
      it_should_behave_like 'admin granted'
      it_should_behave_like 'update only'
    end
  end

  context 'for SupplierBankAccount' do
    context 'requested by non supplier user' do
      let(:ability) { Spree::SupplierAbility.new(create(:user)) }
      let(:resource) { Spree::SupplierBankAccount }

      it_should_behave_like 'admin denied'
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::SupplierBankAccount.new({supplier: user.supplier}, without_protection: true) }
      it_should_behave_like 'admin granted'
      it_should_behave_like 'access granted'
    end

    context 'requested by another suppliers user' do
      let(:resource) { Spree::SupplierBankAccount.new({supplier: create(:supplier)}, without_protection: true) }
      it_should_behave_like 'create only'
    end
  end

  context 'for Variant' do
    let(:resource) { Spree::Variant }

    it_should_behave_like 'index allowed'
    it_should_behave_like 'admin granted'

    context 'requested by another suppliers user' do
      let(:resource) { Spree::Variant.new({product: create(:product, supplier: create(:supplier))}, without_protection: true) }
      it_should_behave_like 'access denied'
    end

    context 'requested by suppliers user' do
      let(:resource) { Spree::Variant.new({product: create(:product, supplier: user.supplier)}, without_protection: true) }
      it_should_behave_like 'access granted'
    end
  end

end
