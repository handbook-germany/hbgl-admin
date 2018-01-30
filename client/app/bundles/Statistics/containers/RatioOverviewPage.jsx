import { connect } from 'react-redux'
import values from 'lodash/values'
import round from 'lodash/round'
import loadAjaxData from '../../../Backend/actions/loadAjaxData'
import RatioOverviewPage from '../components/RatioOverviewPage'

const mapStateToProps = (state, ownProps) => {
  const data = state.entities.count
  const sections = values(state.entities.sections)

  const allDataLoaded = (
    data && data.offer != undefined && data.offer.ratio != undefined &&
      data.offer.ratio.family != undefined &&
      data.offer.ratio.refugees != undefined &&
      data.organization != undefined && data.organization.ratio != undefined &&
      data.organization.ratio.family != undefined &&
      data.organization.ratio.refugees != undefined
  )

  const calculateRatio = (section) => {
    return data.offer.ratio[section] == 0 || data.organization.ratio[section] == 0 ? 0.0 :
      round(data.offer.ratio[section] / data.organization.ratio[section], 2)
  }

  let familyRatio = 'Lade…'
  let refugeesRatio = 'Lade…'
  let totalRatio = 'Lade…'

  if (allDataLoaded) {
    familyRatio = calculateRatio('family')
    refugeesRatio = calculateRatio('refugees')
    totalRatio = calculateRatio('total')
  }

  return {
    familyRatio,
    refugeesRatio,
    totalRatio,
    sections,
  }
}

const mapDispatchToProps = (dispatch, ownProps) => ({
  dispatch
})

const mergeProps = (stateProps, dispatchProps, ownProps) => {
  const { dispatch } = dispatchProps

  const entryCountGrabberTransformer = function(model, section) {
    return function(json) {
      let obj = {}
      obj[model] = {}
      obj[model].ratio = {}
      obj[model].ratio[section.identifier || section] =
        json.meta.total_entries
      return { count: obj }
    }
  }

  const entryCountGrabberParams = function(model, section) {
    let params = { per_page: 1 }
    params['filters[organizations.aasm-state]'] = 'all_done'

    if (typeof section == 'object') {
      let sectionName =
        model == 'offer' ? 'section-id' : 'sections.id'
      params[`filters[${sectionName}]`] = section.id
    }

    return params
  }

  const dispatchDataLoad = function(section) {
    for (let model of ['offer', 'organization'])
    dispatch(
      loadAjaxData(
        `${model}s`, entryCountGrabberParams(model, section),
        'lastData',
        { transformer: entryCountGrabberTransformer(model, section) }
      )
    )
  }

  return({
    ...stateProps,
    ...dispatchProps,
    ...ownProps,

    loadSections() {
      dispatch(loadAjaxData('sections', {}, 'sections'))
    },

    loadData(sections) {
      for (let section of sections) {
        dispatchDataLoad(section)
      }
      dispatchDataLoad('total')
    }
  })
}

export default connect(mapStateToProps, mapDispatchToProps, mergeProps)(
  RatioOverviewPage
)
