import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="app">
      <header className="app-header">
        <img src={logo} className="app-logo" alt="logo" />
        <p>
        This is a CICD project that dockerises a nodejs website created with "npx create-react-app".

        The code is pushed to GitHub, where a GitHub Actions workflow uses Terraform scripts to provision the Infrastructure on AWS.

        The docker image is pushed to AWS ECR from where it is run on the provisioned EC2 instance.

        The deployment is managed by GitHub Actions

        The image was updated and pushed on May 27, 2023
        </p>
        <a
          className="app-link"
          href="https://github.com/Sanim16/cicddemo_with_terraform_on_aws"
          target="_blank"
          rel="noopener noreferrer"
        >
          Link to the GitHub Repo
        </a>
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <a
          className="app-link"
          href="https://reactjs.org"
          target="_blank"
          rel="noopener noreferrer"
        >
          Learn React
        </a>
      </header>
    </div>
  );
}

export default App;
