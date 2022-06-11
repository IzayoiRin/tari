#!/bin/bash

TEMP_DIR="$(pwd)/temps"
TEMPLATE_DIR="$(pwd)/template"
TEMPLATE_CONFIG_DIR="${TEMPLATE_DIR}/config"
TEMPLATE_IMAGINE_DIR="${TEMPLATE_DIR}/imagine"
TEMPLATE_COMPOSE_DIR="${TEMPLATE_DIR}/docker_compose"

TEMPLATE_RABBITMQ_CONFIG="${TEMPLATE_CONFIG_DIR}/rabbitmq.config"
TEMPLATE_REDIS_CONFIG="${TEMPLATE_CONFIG_DIR}/redis.conf"
TEMPLATE_DOCKER_SERVICE_IMAGINES="${TEMPLATE_IMAGINE_DIR}/services"
TEMPLATE_DOCKER_SERVICE_YAML="${TEMPLATE_COMPOSE_DIR}/services.yaml"

DOCKER_YAML_DIR="${TEMP_DIR}/docker_compose"
DOCKER_SERVICE_YAML="${DOCKER_YAML_DIR}/services.yaml"


function log_success(){
    DATA_NOW="$(date +"%Y-%m-%d %H:%M:%S")"
    echo -e "[\033[32mSUCCESS\033[0m] ${DATA_NOW} $@."
}


function log_error(){
    DATA_NOW="$(date +"%Y-%m-%d %H:%M:%S")"
    echo -e "[\033[41;37mERROR\033[0m] ${DATA_NOW} $@."
}


function log_info(){
    DATA_NOW="$(date +"%Y-%m-%d %H:%M:%S")"
    echo -e "[INFO] ${DATA_NOW} $@."
}


function sysexit(){
    log_error $@
    exit 1
}


function read_config(){
    sed -n "/${1}=/{s/${1}=//g;p;q}" ${CONFIG}
}


function copy_file(){
    src=${1}
    dest=${2}
    
    dirpath=$(dirname ${dest})
    test -d ${dirpath} || mkdir -p ${dirpath}
    cp -v ${src} ${dirpath}
}


function create_docker_container(){
    test -d ${TEMP_DIR} || mkdir -p ${DOCKER_YAML_DIR}

    NETWORK=$(read_config NETWORK)

    DOCKER_DATA_PATH=$(read_config DOCKER_DATA_PATH)

    log_info "Cleaning docker data ..."
    test -d ${DOCKER_DATA_PATH} && rm -rfv /d/Tools/docker/* && log_success "Data cleaned [${DOCKER_DATA_PATH}]"

    RABBITMQ_CONFIG_FILE=$(read_config RABBITMQ_CONFIG_REFER_PATH)
    REDIS_CONFIG_FILE=$(read_config REDIS_CONFIG_REFER_PATH)
    
    # copy_file "${TEMPLATE_RABBITMQ_CONFIG}" "${DOCKER_DATA_PATH}/${RABBITMQ_CONFIG_FILE}"
    copy_file "${TEMPLATE_REDIS_CONFIG}" "${DOCKER_DATA_PATH}/${REDIS_CONFIG_FILE}"

    # sed template variable
    log_info "Configuring docker compose ..."
    sed -e "s%{{DOCKER_DATA}}%${DOCKER_DATA_PATH}%g" \
        -e "s%{{EXT_NETWORK}}%$(read_config NETWORK)%g" \
        -e "s%{{TIME_ZONE}}%$(read_config TIME_ZONE)%g" \
        -e "s%{{RABBITMQ_PORT}}%$(read_config RABBITMQ_PORT)%g" \
        -e "s%{{RABBITMQ_APIS_PORT}}%$(read_config RABBITMQ_APIS_PORT)%g" \
        -e "s%{{RABBITMQ_USER}}%$(read_config RABBITMQ_USER)%g" \
        -e "s%{{RABBITMQ_PASSWORD}}%$(read_config RABBITMQ_PASSWORD)%g" \
        -e "s%{{RABBITMQ_VHOST}}%$(read_config RABBITMQ_VHOST)%g" \
        -e "s%{{RABBITMQ_CONFIG_REFER_PATH}}%${RABBITMQ_CONFIG_FILE}%g" \
        -e "s%{{MYSQL_PORT}}%$(read_config MYSQL_PORT)%g" \
        -e "s%{{MYSQL_ROOT_PASSWORD}}%$(read_config MYSQL_ROOT_PASSWORD)%g" \
        -e "s%{{MYSQL_DEFAULT_DB}}%$(read_config MYSQL_DEFAULT_DB)%g" \
        -e "s%{{REDIS_PORT}}%$(read_config REDIS_PORT)%g" \
        -e "s%{{REDIS_PASSWORD}}%$(read_config REDIS_PASSWORD)%g" \
        -e "s%{{REDIS_CONFIG_REFER_PATH}}%${REDIS_CONFIG_FILE}%g" \
        ${TEMPLATE_DOCKER_SERVICE_YAML} > ${DOCKER_SERVICE_YAML} \
        && log_success "Compose generated [${DOCKER_SERVICE_YAML}]"

    log_info "Cleaning docker imagines ..."
    ls ${TEMPLATE_DOCKER_SERVICE_IMAGINES} | 
    awk '{sub(/\.tar/, ""); print $0}' | awk '{sub(/\+/, ":"); print $0}' | 
    xargs -n1 docker image rm -f && log_success "Imagines cleared"

    log_info "Loading docker imagines ..."
    ls ${TEMPLATE_DOCKER_SERVICE_IMAGINES} | 
    awk -v dir="${TEMPLATE_DOCKER_SERVICE_IMAGINES}/" '{print dir$1}' | 
    xargs -n1 docker image load -i && log_success "Imagines loaded"

    log_info "Creating docker network ..."
    docker network create ${NETWORK} && log_success "Network created [${NETWORK}]"

    log_info "Launching services"
    docker-compose -f ${DOCKER_SERVICE_YAML} up -d && log_success "Services started"
}


function delete_docker_container(){
    test -f ${DOCKER_SERVICE_YAML} || sysexit "Compose Not found [${DOCKER_SERVICE_YAML}]"
    
    log_info "Stopping services"
    docker-compose -f ${DOCKER_SERVICE_YAML} down && log_success "Services stop"

    log_info "Deleting docker network ..."
    NETWORK=$(read_config NETWORK)
    docker network rm ${NETWORK} && log_success "Network deleted [${NETWORK}]"

    log_info "Cleaning docker data ..."
    test -d ${DOCKER_DATA_PATH} && rm -rfv /d/Tools/docker/* && log_success "Data cleaned [${DOCKER_DATA_PATH}]"
}


function main(){
    opt="${1}"
    export CONFIG="$(pwd)/${2}"
    shift 2
    
    if [[ "${opt}" =~ ^(intall)|(-i)$ ]];then
        test -d ${TEMP_DIR} && rm -rf ${TEMP_DIR}
        create_docker_container

    elif [[ "${opt}" =~ ^(uninstall)|(-u)$ ]];then
        delete_docker_container
        test -d ${TEMP_DIR} && rm -rf ${TEMP_DIR}
    fi

    unset CONFIG
}


main $@
