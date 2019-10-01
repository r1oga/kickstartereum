import React, { Component } from 'react'
import { Form, Input, Message, Button } from 'semantic-ui-react'

import Campaign from '../ethereum/campaign'
import web3 from '../ethereum/web'

class ContributeForm extends Component {
  state = {
    value: '',
    errorMessage: '',
    loading: ''
  }

  onSubmit = async (event) => {
    event.preventDefault()
    const campaign = Campaign(this.props.address)
    const accounts = await web3.eth.getCaaounts()
    try {
      await campaign.methods.contribute.send({
        from: accounts[0],
        value: web3.utils.toWei(`this.state.value`, 'ether')
      })
    } catch (error) {
      this.setState({ errorMessage: error.message })
    }
  }

  render () {
    return (
      <Form onSubmit={this.onSubmit}>
        <Form.Field>
          <label>Amount to contribute</label>
          <Input
            label='ether'
            labelPosition='right'
            value={this.state.value}
            onChange={(event) => this.setState({value: event.target.value})}
          />
        </Form.Field>
        <Button primary>Contribute!</Button>
      </Form>
    )
  }
}

export default ContributeForm