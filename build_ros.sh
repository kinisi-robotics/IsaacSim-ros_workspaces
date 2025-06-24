#!/bin/bash

set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Display help function
function display_help {
  echo "Usage: $0 [options]"
  echo ""
  echo "Build the ROS2 workspace using Docker."
  echo ""
  echo "Options:"
  echo "  -d DISTRO     Specify ROS2 distro (humble or jazzy)"
  echo "  -v VERSION    Specify Ubuntu version (22.04 or 24.04)"
  echo "  -h            Display this help message"
  echo ""
  echo "Supported combinations:"
  echo "  - humble: Ubuntu 22.04"
  echo "  - jazzy:  Ubuntu 22.04 or 24.04"
  echo ""
  echo "If no options are specified, the script will detect your current Ubuntu version"
  echo "and select: Ubuntu 22.04 -> Humble, Ubuntu 24.04 -> Jazzy"
}

# Add command-line arguments
UBUNTU_VERSION="24.04"
ROS_DISTRO="jazzy"

# Update git submodules in the repo
echo "Updating git submodules..."
git submodule update --init --recursive


# Select the appropriate Docker file
DOCKERFILE="dockerfiles/ubuntu_24_jazzy_python_311_minimal.dockerfile" 
echo "Using Ubuntu 24.04 with ROS Jazzy"

# Build the Docker image
docker build . --network=host -f $DOCKERFILE -t isaac_sim_ros:ubuntu_${UBUNTU_VERSION%.*}_${ROS_DISTRO}

# Prepare the target directory
rm -rf build_ws/${ROS_DISTRO}
mkdir -p build_ws/${ROS_DISTRO}

pushd build_ws/${ROS_DISTRO}

# Extract files from Docker container
docker cp $(docker create --rm isaac_sim_ros:ubuntu_${UBUNTU_VERSION%.*}_${ROS_DISTRO}):/workspace/${ROS_DISTRO}_ws ${ROS_DISTRO}_ws

docker cp $(docker create --rm isaac_sim_ros:ubuntu_${UBUNTU_VERSION%.*}_${ROS_DISTRO}):/workspace/build_ws isaac_sim_ros_ws

popd

echo "Build complete for $ROS_DISTRO on Ubuntu $UBUNTU_VERSION" 