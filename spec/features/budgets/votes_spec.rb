require 'rails_helper'

describe 'Votes' do

  before do
    @manuela = create(:user, verified_at: Time.current)
  end

  describe 'Investments' do

    let(:budget)  { create(:budget, phase: "selecting") }
    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    before { login_as(@manuela) }

    describe 'Index' do

      it "Index shows user votes on proposals" do
        investment1 = create(:budget_investment, heading: heading)
        investment2 = create(:budget_investment, heading: heading)
        investment3 = create(:budget_investment, heading: heading)
        create(:vote, voter: @manuela, votable: investment1, vote_flag: true)

        visit budget_investments_path(budget, heading_id: heading.id)

        within("#budget-investments") do
          within("#budget_investment_#{investment1.id}_votes") do
            expect(page).to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment2.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end

          within("#budget_investment_#{investment3.id}_votes") do
            expect(page).not_to have_content "You have already supported this investment project. Share it!"
          end
        end
      end

      it 'Create from spending proposal index', :js do
        investment = create(:budget_investment, heading: heading, budget: budget)

        visit budget_investments_path(budget, heading_id: heading.id)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end
      end
    end

    describe 'Single spending proposal' do
      before do
        @investment = create(:budget_investment, budget: budget, heading: heading)
      end

      it 'Show no votes' do
        visit budget_investment_path(budget, @investment)
        expect(page).to have_content "No supports"
      end

      it 'Trying to vote multiple times', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click
          expect(page).to have_content "1 support"

          expect(page).not_to have_selector ".in-favor a"
        end
      end

      it 'Create from proposal show', :js do
        visit budget_investment_path(budget, @investment)

        within('.supports') do
          find('.in-favor a').click

          expect(page).to have_content "1 support"
          expect(page).to have_content "You have already supported this investment project. Share it!"
        end
      end
    end

    it 'Disable voting on spending proposals', :js do
      login_as(@manuela)
      budget.update(phase: "reviewing")
      investment = create(:budget_investment, budget: budget, heading: heading)

      visit budget_investments_path(budget, heading_id: heading.id)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end

      visit budget_investment_path(budget, investment)

      within("#budget_investment_#{investment.id}") do
        expect(page).not_to have_css("budget_investment_#{investment.id}_votes")
      end
    end
  end
end
