import { connect } from 'react-redux'
import toPairs from 'lodash/toPairs'
import values from 'lodash/values'
import keys from 'lodash/keys'
import settings from '../../../lib/settings'
import { pluralize } from '../../../lib/inflection'
import loadAjaxData from '../../../Backend/actions/loadAjaxData'
import addEntities from '../../../Backend/actions/addEntities'
import OverviewTable from '../components/OverviewTable'

const ALL = 'all'

const mapStateToProps = (state, ownProps) => {
  const stateKey = `statisticsOverview_${ownProps.model}`
  const states = (state.ajax[stateKey] && state.ajax[stateKey].states) || []
  const selectedCity = state.rform[stateKey] && state.rform[stateKey].city
  const data =
    (state.entities.count && state.entities.count[ownProps.model] &&
      state.entities.count[ownProps.model][selectedCity || ALL]) || {}
  const sections =
    values(state.entities.filters).filter(obj => obj.type == 'SectionFilter')
  const loadedCities =
    (state.entities.count && keys(state.entities.count[ownProps.model])) || []

  return {
    data,
    states,
    stateKey,
    sections,
    selectedCity,
    loadedCities,
  }
}

const mapDispatchToProps = (dispatch, ownProps) => ({
  dispatch
})

const mergeProps = (stateProps, dispatchProps, ownProps) => {
  const { model, cityAssociationName } = ownProps
  const { dispatch } = dispatchProps

  const entryCountGrabberTransformer = function(aasm_state, section, cityId) {
    return function(json) {
      const sectionKey = section.identifier || section
      const stateKey = aasm_state || 'total'
      const cityKey = cityId || ALL

      let obj = {}
      obj[model] = {}
      obj[model][cityKey] = {}
      obj[model][cityKey][stateKey] = {}
      obj[model][cityKey][stateKey][sectionKey] = json.meta.total_entries
      return { count: obj }
    }
  }

  const entryCountGrabberParams = function(aasm_state, section, cityId) {
    let params = { per_page: 1 }
    if (cityId) params[`filter[${cityAssociationName}.id]`] = cityId
    if (aasm_state)
      params[`filter[${pluralize(model)}.aasm_state]`] = aasm_state
    if (typeof section == 'object')
      params['filter[section_filters.id]'] = section.id
    return params
  }

  const dispatchDataLoad = function(aasm_state, section, cityId) {
    dispatch(
      loadAjaxData(
        model + 's',
        entryCountGrabberParams(aasm_state, section, cityId),
        'lastData',
        entryCountGrabberTransformer(aasm_state, section, cityId)
      )
    )
  }

  const loadData = function(states, cityId) {
    for (let aasm_state of states.concat(null)) { // null for the "total" row
      for (let section of stateProps.sections) {
        dispatchDataLoad(aasm_state, section, cityId)
      }
      dispatchDataLoad(aasm_state, 'total', cityId)
    }
  }

  return({
    ...stateProps,
    ...dispatchProps,
    ...ownProps,

    loadData,

    loadStates() {
      dispatch(
        loadAjaxData(
          `states/${model}`, {}, stateProps.stateKey, () => ({})
        )
      )
    },

    onCityChange(selected) {
      const city = (selected && selected.value) || ALL
      if (!stateProps.loadedCities.includes(city))
        loadData(stateProps.states, selected.value)
    }
  })
}

export default connect(mapStateToProps, mapDispatchToProps, mergeProps)(
  OverviewTable
)