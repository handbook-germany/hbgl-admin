import React, { PropTypes } from 'react'
import OverviewPanel from '../components/OverviewPanel'
import CollapsiblePanel from '../../CollapsiblePanel/containers/CollapsiblePanel'
import ActualWaList from './ActualWaList'

export default class Dashboard extends React.Component {
  static propTypes = {
    hasOutstandingTimeAllocations: PropTypes.bool.isRequired,
    outstandingTimeAllocations: PropTypes.array.isRequired,
  }

  render() {

    const {
      user, hasOutstandingTimeAllocations, outstandingTimeAllocations
    } = this.props
    const actualWa = hasOutstandingTimeAllocations ? (
      <ActualWaList outstandingTimeAllocations={outstandingTimeAllocations} />
    ) : null

    return (
      <div className='Dashboard'>
        <h1 className="page-title">Dashboard</h1>
        {actualWa}
        <CollapsiblePanel
          title={`Willkommen, ${user.name}`} identifier='dashboard'
          visible={true}
        >
          <OverviewPanel params={this.props.location.query}/>
        </CollapsiblePanel>
      </div>
    )
  }
}
