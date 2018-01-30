import React, { PropTypes } from 'react'
import { Router, Route, browserHistory, IndexRoute } from 'react-router'

import Layout from './Layout'
import Index from '../../bundles/Index/containers/Index'
import MemberAction from '../../bundles/MemberAction/containers/MemberAction'
import StandaloneGenericForm
  from '../../bundles/GenericForm/containers/Standalone'
import Export from '../../bundles/Export/containers/Export'
import DashboardContainer
  from '../../bundles/Dashboard/containers/DashboardContainer'
import NewAssignment
  from '../../bundles/NewAssignment/containers/NewAssignmentForm'
import StatisticsLayout
  from '../../bundles/Statistics/components/StatisticsLayout'
import Overview from '../../bundles/Statistics/components/Overview'
import OfferOverviewPage
  from '../../bundles/Statistics/components/OfferOverviewPage'
import OrgaOverviewPage
  from '../../bundles/Statistics/components/OrgaOverviewPage'
import OrgaTopicOverviewPage
  from '../../bundles/Statistics/components/OrgaTopicOverviewPage'
import OrgaScreeningOverviewPage
  from '../../bundles/Statistics/components/OrgaScreeningOverviewPage'
import OrgaOfferCitiesOverview
  from '../../bundles/Statistics/components/OrgaOfferCitiesOverviewPage'
import RatioOverviewPage
  from '../../bundles/Statistics/containers/RatioOverviewPage'
import EditTranslation from
  '../../bundles/EditTranslation/containers/EditTranslation'

export default class Routes extends React.Component {
  componentDidMount() {
    this.props.initialSetup()
  }

  render() {
    return (
      <Router history={browserHistory}>
        <Route path='/' component={Layout}>
          <IndexRoute component={DashboardContainer}/>

          <Route path='organizations'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='divisions'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='offers'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
            <Route path=':id/duplicate' component={MemberAction} />
          </Route>

          <Route path='subscriptions'>
            <IndexRoute component={Index}/>
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='update-requests'>
            <IndexRoute component={Index}/>
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='locations'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='cities'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='openings'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='tags'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='definitions'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='federal-states'>
            <IndexRoute component={Index}/>
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='contact-people'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='next-steps'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='areas'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='logic-versions'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='emails'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='solution-categories'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='websites'>
            <IndexRoute component={Index}/>
            <Route path='new' component={StandaloneGenericForm} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
            <Route path=':id/delete' component={MemberAction} />
          </Route>

          <Route path='statistics' component={StatisticsLayout}>
            <IndexRoute component={Overview}/>
            <Route path='offer-overview' component={OfferOverviewPage} />
            <Route path='organization-overview' component={OrgaOverviewPage} />
            <Route path='screening-overview' component={OrgaScreeningOverviewPage} />
            <Route path='topic-overview' component={OrgaTopicOverviewPage} />
            <Route path='orga-offer-cities-overview'
              component={OrgaOfferCitiesOverview}
            />
            <Route path='ratio-overview' component={RatioOverviewPage} />
            {/*
            <Route path='offer-created' component={OfferCreatedPage} />
            <Route path='offer-approved' component={OfferApprovedPage} />
            <Route path='organization-created' component={OrgaCreatedPage} />
            <Route path='organization-approved' component={OrgaApprovedPage} />
            */}
          </Route>

          <Route path='offer-translations'>
            <IndexRoute component={Index} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={EditTranslation} model='offer' />
          </Route>

          <Route path='organization-translations'>
            <IndexRoute component={Index} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={EditTranslation}
              model='organization'
            />
          </Route>

          <Route path='user-teams'>
            <IndexRoute component={Index} />
            <Route path='new' component={StandaloneGenericForm} />
            <Route path=':id' component={MemberAction} />
            <Route path=':id/edit' component={MemberAction} />
          </Route>

          <Route path='users'>
            <IndexRoute component={Index} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='assignments'>
            <IndexRoute component={Index} />
            <Route path='new' component={NewAssignment} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='search-locations'>
            <IndexRoute component={Index} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='language-filters'>
            <IndexRoute component={Index} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='contacts'>
            <IndexRoute component={Index} />
            <Route path='export' component={Export} />
            <Route path=':id' component={MemberAction} />
          </Route>

          <Route path='sections'>
            <IndexRoute component={Index}/>
            <Route path=':id' component={MemberAction} />
          </Route>
        </Route>
      </Router>
    )
  }
}
